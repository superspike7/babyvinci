class GoogleCalendarSyncService
  def self.sync_reminder(reminder:, creating_user:)
    new(reminder: reminder, creating_user: creating_user).sync
  end

  def self.clear_reminder(reminder:, creating_user:)
    new(reminder: reminder, creating_user: creating_user).clear
  end

  def initialize(reminder:, creating_user:)
    @reminder = reminder
    @creating_user = creating_user
  end

  def sync
    return unless should_sync?

    begin
      if @reminder.google_calendar_event_id.present?
        update_existing_event
      else
        create_new_event
      end
      @reminder.update_column(:calendar_sync_failed_at, nil)
    rescue Google::Apis::Error, OAuth2::Error, Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ETIMEDOUT => e
      error_details = "#{e.class}"
      if e.respond_to?(:status_code)
        error_details += " status=#{e.status_code}"
      end
      if e.respond_to?(:message) && e.message
        # Sanitize message to avoid leaking tokens
        safe_message = e.message.to_s.gsub(/(token|access_token|refresh_token|code)=[^\s&]+/, "[FILTERED]")
        error_details += " message=#{safe_message[0..100]}"
      end
      Rails.logger.error "Google Calendar sync failed for reminder #{@reminder.id}: #{error_details}"
      @reminder.update_column(:calendar_sync_failed_at, Time.current)
    end
  end

  def clear
    return unless should_sync? && @reminder.google_calendar_event_id.present?

    begin
      calendar_service.delete_event(calendar_id, @reminder.google_calendar_event_id)
    rescue Google::Apis::Error, OAuth2::Error, Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ETIMEDOUT => e
      Rails.logger.error "Google Calendar delete failed for reminder #{@reminder.id}: #{e.class}"
    end
  end

  private

  def should_sync?
    @creating_user.google_calendar_connected?
  end

  def create_new_event
    event = build_event
    result = calendar_service.insert_event(
      calendar_id,
      event,
      send_notifications: true
    )
    @reminder.update_columns(
      google_calendar_event_id: result.id,
      calendar_owner_user_id: @creating_user.id
    )
  end

  def update_existing_event
    event = build_event
    calendar_service.update_event(
      calendar_id,
      @reminder.google_calendar_event_id,
      event,
      send_notifications: true
    )
  end

  def build_event
    Google::Apis::CalendarV3::Event.new(
      summary: "Feed #{@reminder.baby.first_name}",
      description: "Next feed reminder from BabyVinci",
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: @reminder.target_at.iso8601,
        time_zone: Time.zone.name
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: (@reminder.target_at + 30.minutes).iso8601,
        time_zone: Time.zone.name
      ),
      attendees: connected_family_members,
      reminders: Google::Apis::CalendarV3::Event::Reminders.new(
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(
            method: "popup",
            minutes: 10
          )
        ]
      )
    )
  end

  def connected_family_members
    @reminder.baby.users
      .where.not(google_access_token: [ nil, "" ])
      .where.not(google_calendar_email: [ nil, "" ])
      .map do |user|
        Google::Apis::CalendarV3::EventAttendee.new(
          email: user.google_calendar_email,
          response_status: "needsAction"
        )
      end
  end

  def calendar_service
    @calendar_service ||= begin
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = user_credentials
      service
    end
  end

  def user_credentials
    @user_credentials ||= begin
      token = @creating_user.google_access_token

      if token_expired?
        token = refresh_access_token
      end

      Google::Auth::UserRefreshCredentials.new(
        client_id: Rails.application.credentials.dig(:google, :client_id),
        client_secret: Rails.application.credentials.dig(:google, :client_secret),
        scope: "https://www.googleapis.com/auth/calendar.events",
        access_token: token
      )
    end
  end

  def token_expired?
    return true if @creating_user.google_token_expires_at.blank?
    @creating_user.google_token_expires_at <= Time.current
  end

  def refresh_access_token
    oauth_client = OAuth2::Client.new(
      Rails.application.credentials.dig(:google, :client_id),
      Rails.application.credentials.dig(:google, :client_secret),
      {
        site: "https://accounts.google.com",
        authorize_url: "/o/oauth2/v2/auth",
        token_url: "https://oauth2.googleapis.com/token"
      }
    )

    token = OAuth2::AccessToken.new(
      oauth_client,
      @creating_user.google_access_token,
      refresh_token: @creating_user.google_refresh_token
    )

    new_token = token.refresh!

    @creating_user.update!(
      google_access_token: new_token.token,
      google_token_expires_at: Time.at(new_token.expires_at)
    )

    new_token.token
  rescue OAuth2::Error => e
    Rails.logger.error "Failed to refresh Google OAuth token for user #{@creating_user.id}: #{e.message}"
    @creating_user.clear_google_calendar_connection!
    nil
  end

  def calendar_id
    "primary"
  end
end
