require "test_helper"

class GoogleCalendarConnectionsTest < ActionDispatch::IntegrationTest
  setup do
    # Stub Google OAuth credentials for testing
    @original_credentials = Rails.application.credentials.google
    Rails.application.credentials.google = {
      client_id: "test_client_id",
      client_secret: "test_client_secret"
    }
  end

  teardown do
    Rails.application.credentials.google = @original_credentials
  end

  test "user can connect a Google Calendar account through OAuth callback" do
    user = users(:one)
    create_baby_for(user)

    sign_in_as(user)

    assert_nil user.google_access_token
    assert_nil user.google_refresh_token

    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      get google_calendar_connection_callback_path, params: {
        code: "test_authorization_code"
      }
    end

    assert_redirected_to more_path
    follow_redirect!
    assert_match "Google Calendar connected successfully.", response.body

    user.reload
    assert_equal "test_access_token", user.google_access_token
    assert_equal "test_refresh_token", user.google_refresh_token
    assert_not_nil user.google_token_expires_at
    assert_equal "user@gmail.com", user.google_calendar_email
  end

  test "user can disconnect their Google Calendar account" do
    user = users(:one)
    create_baby_for(user)
    user.update!(
      google_access_token: "existing_token",
      google_refresh_token: "existing_refresh",
      google_token_expires_at: 1.hour.from_now,
      google_calendar_email: "user@gmail.com"
    )

    sign_in_as(user)

    assert user.google_calendar_connected?

    delete google_calendar_connection_path

    assert_redirected_to more_path
    follow_redirect!
    assert_match "Google Calendar disconnected.", response.body
    assert_match "Connect your Google Calendar", response.body

    user.reload
    assert_nil user.google_access_token
    assert_nil user.google_refresh_token
    assert_nil user.google_token_expires_at
    assert_nil user.google_calendar_email
    assert_not user.google_calendar_connected?
  end

  test "connection state is scoped to the current user and not shared" do
    owner = users(:one)
    partner = users(:two)
    baby = create_baby_for(owner)
    BabyMembership.create!(baby: baby, user: partner, role: "parent")

    owner.update!(
      google_access_token: "owner_token",
      google_refresh_token: "owner_refresh",
      google_token_expires_at: 1.hour.from_now,
      google_calendar_email: "owner@gmail.com"
    )

    sign_in_as(partner)
    get more_path

    assert_response :success
    assert_match "Connect your Google Calendar", response.body
    assert_no_match "owner@gmail.com", response.body
    assert_no_match "Disconnect", response.body

    partner.reload
    assert_nil partner.google_access_token
    assert_not partner.google_calendar_connected?
  end

  test "more page shows connected state when user has Google Calendar connected" do
    user = users(:one)
    create_baby_for(user)
    user.update!(
      google_access_token: "test_token",
      google_refresh_token: "test_refresh",
      google_token_expires_at: 1.hour.from_now,
      google_calendar_email: "parent@gmail.com"
    )

    sign_in_as(user)
    get more_path

    assert_response :success
    assert_match "Google Calendar connected", response.body
    assert_match "parent@gmail.com", response.body
    assert_match "Disconnect", response.body
    assert_match "Your next-feed reminders will appear in your Google Calendar.", response.body
  end

  test "more page shows connect button when user has no Google Calendar connection" do
    user = users(:one)
    create_baby_for(user)

    sign_in_as(user)
    get more_path

    assert_response :success
    assert_match "Connect your Google Calendar", response.body
    assert_match "Connect Google Calendar", response.body
    assert_match "Get reminders on your phone through your existing calendar.", response.body
  end

  test "reminder feature still works without calendar connection" do
    user = users(:one)
    baby = create_baby_for(user)

    sign_in_as(user)

    assert_not user.google_calendar_connected?

    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T11:30" }
      }
    end

    assert_redirected_to today_path
    assert_equal Time.zone.local(2026, 3, 24, 11, 30), baby.reload.next_feed_reminder.target_at
  end

  private
    def create_baby_for(user, first_name: "Vinci")
      BabyCreator.create!(
        user: user,
        first_name: first_name,
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )
    end

    def sign_in_as(user)
      post session_path, params: { email: user.email, password: "password" }
    end
end
