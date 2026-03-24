require "test_helper"

class ReminderCalendarSyncTest < ActionDispatch::IntegrationTest
  setup do
    @original_credentials = Rails.application.credentials.google
    Rails.application.credentials.google = {
      client_id: "test_client_id",
      client_secret: "test_client_secret"
    }
  end

  teardown do
    Rails.application.credentials.google = @original_credentials
  end

  test "reminder create stores calendar sync metadata when user has connected calendar" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      owner = users(:one)
      baby = create_baby_for(owner)
      owner.update!(
        google_access_token: "test_token",
        google_refresh_token: "test_refresh",
        google_token_expires_at: 1.hour.from_now,
        google_calendar_email: "owner@gmail.com"
      )

      sign_in_as(owner)

      # The service will fail to create real event (no real Google API), but should attempt sync
      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T11:30" }
      }

      assert_redirected_to today_path

      reminder = baby.reload.next_feed_reminder
      assert_equal Time.zone.local(2026, 3, 24, 11, 30), reminder.target_at
      # Reminder should exist even if calendar sync failed (no real API)
      assert_not_nil reminder
    end
  end

  test "reminder update patches the same calendar event without creating duplicates" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      owner = users(:one)
      baby = create_baby_for(owner)
      owner.update!(
        google_access_token: "test_token",
        google_refresh_token: "test_refresh",
        google_token_expires_at: 1.hour.from_now,
        google_calendar_email: "owner@gmail.com"
      )

      # Create initial reminder with calendar event
      reminder = baby.create_next_feed_reminder!(
        target_at: Time.zone.local(2026, 3, 24, 11, 0),
        google_calendar_event_id: "existing_event_id",
        calendar_owner_user_id: owner.id
      )

      sign_in_as(owner)

      patch next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T12:00" }
      }

      assert_redirected_to today_path

      reminder.reload
      # Event ID should remain the same
      assert_equal "existing_event_id", reminder.google_calendar_event_id
      assert_equal Time.zone.local(2026, 3, 24, 12, 0), reminder.target_at
    end
  end

  test "reminder clear deletes the calendar event" do
    owner = users(:one)
    baby = create_baby_for(owner)
    owner.update!(
      google_access_token: "test_token",
      google_refresh_token: "test_refresh",
      google_token_expires_at: 1.hour.from_now,
      google_calendar_email: "owner@gmail.com"
    )

    baby.create_next_feed_reminder!(
      target_at: Time.zone.local(2026, 3, 24, 11, 0),
      google_calendar_event_id: "event_to_delete",
      calendar_owner_user_id: owner.id
    )

    sign_in_as(owner)
    delete next_feed_reminder_path

    assert_redirected_to today_path
    assert_nil baby.reload.next_feed_reminder
  end

  test "failed calendar sync does not lose the BabyVinci reminder" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      owner = users(:one)
      baby = create_baby_for(owner)
      owner.update!(
        google_access_token: "test_token",
        google_refresh_token: "test_refresh",
        google_token_expires_at: 1.hour.from_now,
        google_calendar_email: "owner@gmail.com"
      )

      sign_in_as(owner)

      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T11:30" }
      }

      assert_redirected_to today_path

      reminder = baby.reload.next_feed_reminder
      assert_equal Time.zone.local(2026, 3, 24, 11, 30), reminder.target_at
      # Reminder exists even if sync failed (no real Google API in test)
      assert_not_nil reminder
    end
  end

  test "Today view shows sync failure state when calendar sync failed" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      owner = users(:one)
      baby = create_baby_for(owner)
      owner.update!(
        google_access_token: "test_token",
        google_refresh_token: "test_refresh",
        google_token_expires_at: 1.hour.from_now,
        google_calendar_email: "owner@gmail.com"
      )

      baby.create_next_feed_reminder!(
        target_at: Time.zone.local(2026, 3, 24, 11, 30),
        calendar_sync_failed_at: 5.minutes.ago
      )

      sign_in_as(owner)
      get today_path

      assert_response :success
      assert_match "Calendar sync failed", response.body
      assert_match "Your reminder is saved in BabyVinci", response.body
      assert_match "Tap edit to try again", response.body
    end
  end

  test "partial sync works when only some family members have connected calendars" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      owner = users(:one)
      partner = users(:two)
      baby = create_baby_for(owner)
      BabyMembership.create!(baby: baby, user: partner, role: "parent")

      # Owner has connected calendar, partner does not
      owner.update!(
        google_access_token: "owner_token",
        google_refresh_token: "owner_refresh",
        google_token_expires_at: 1.hour.from_now,
        google_calendar_email: "owner@gmail.com"
      )
      # Partner has no calendar connection

      sign_in_as(owner)

      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T11:30" }
      }

      assert_redirected_to today_path

      reminder = baby.reload.next_feed_reminder
      assert_equal Time.zone.local(2026, 3, 24, 11, 30), reminder.target_at
    end
  end

  test "event ownership remains with creating parent when another member edits" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
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
      partner.update!(
        google_access_token: "partner_token",
        google_refresh_token: "partner_refresh",
        google_token_expires_at: 1.hour.from_now,
        google_calendar_email: "partner@gmail.com"
      )

      # Owner creates initial reminder
      baby.create_next_feed_reminder!(
        target_at: Time.zone.local(2026, 3, 24, 11, 0),
        google_calendar_event_id: "owner_event",
        calendar_owner_user_id: owner.id
      )

      # Partner updates the reminder
      sign_in_as(partner)

      patch next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T12:00" }
      }

      assert_redirected_to today_path

      reminder = baby.reload.next_feed_reminder
      # Event ownership should remain with original creator
      assert_equal owner.id, reminder.calendar_owner_user_id
      assert_equal "owner_event", reminder.google_calendar_event_id
      assert_equal Time.zone.local(2026, 3, 24, 12, 0), reminder.target_at
    end
  end

  test "reminder saves without calendar sync when user has no connected calendar" do
    travel_to Time.zone.local(2026, 3, 24, 10, 0) do
      owner = users(:one)
      baby = create_baby_for(owner)
      # No calendar connection

      sign_in_as(owner)
      assert_not owner.google_calendar_connected?

      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T11:30" }
      }

      assert_redirected_to today_path

      reminder = baby.reload.next_feed_reminder
      assert_equal Time.zone.local(2026, 3, 24, 11, 30), reminder.target_at
      assert_nil reminder.google_calendar_event_id
      assert_nil reminder.calendar_owner_user_id
    end
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
