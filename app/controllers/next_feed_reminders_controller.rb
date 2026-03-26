class NextFeedRemindersController < ApplicationController
  before_action :require_current_baby

  def create
    @next_feed_reminder = current_baby.next_feed_reminder || current_baby.build_next_feed_reminder
    @next_feed_reminder.target_at = reminder_target_at

    if @next_feed_reminder.save
      sync_calendar
      redirect_to today_path, notice: reminder_notice(@next_feed_reminder.previously_new_record?)
    else
      load_today_state
      render "home/show", status: :unprocessable_entity
    end
  end

  def update
    @next_feed_reminder = current_baby.next_feed_reminder || current_baby.build_next_feed_reminder
    @next_feed_reminder.target_at = reminder_target_at

    if @next_feed_reminder.save
      sync_calendar
      redirect_to today_path, notice: "Next feed reminder updated."
    else
      load_today_state
      render "home/show", status: :unprocessable_entity
    end
  end

  def destroy
    if current_baby.next_feed_reminder
      clear_calendar(current_baby.next_feed_reminder)
      current_baby.next_feed_reminder.destroy
    end

    redirect_to today_path, notice: "Next feed reminder cleared."
  end

  private
    def reminder_params
      params.require(:next_feed_reminder).permit(:target_at)
    end

    def reminder_target_at
      if preset_minutes.present?
        return Time.current + preset_minutes.minutes
      end

      value = reminder_params[:target_at]
      return nil if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end

    def preset_minutes
      minutes = params[:preset_minutes].to_i
      minutes if [ 30, 60, 120, 180 ].include?(minutes)
    end

    def require_current_baby
      redirect_to new_baby_path unless current_baby
    end

    def load_today_state
      @recent_care_events = visible_care_events.limit(8)
      @last_feed = latest_started_event_for("feed")
      @last_diaper = latest_started_event_for("diaper")
      @active_sleep = current_baby.care_events.active_sleep.first
      @last_sleep = latest_started_event_for("sleep")
      @guidance_notes = Guidance.for_age_in_days(baby_age_in_days(current_baby))
    end

    def baby_age_in_days(baby)
      ((Time.zone.today - baby.birth_at.to_date).to_i + 1).clamp(0, Float::INFINITY)
    end

    def visible_care_events
      current_baby.care_events.includes(:user).started_on_or_before(HomeController::VISIBLE_EVENT_SKEW.from_now).chronological_desc
    end

    def latest_started_event_for(kind)
      visible_care_events.for_kind(kind).first
    end

    def reminder_notice(created)
      created ? "Next feed reminder set." : "Next feed reminder updated."
    end

    def sync_calendar
      owner = @next_feed_reminder.calendar_owner || Current.user
      GoogleCalendarSyncService.sync_reminder(
        reminder: @next_feed_reminder,
        creating_user: owner
      )
    end

    def clear_calendar(reminder)
      GoogleCalendarSyncService.clear_reminder(
        reminder: reminder,
        creating_user: Current.user
      )
    end
end
