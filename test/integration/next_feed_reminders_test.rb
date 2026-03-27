require "test_helper"

class NextFeedRemindersTest < ActionDispatch::IntegrationTest
  test "setting a reminder stores one shared reminder for the signed in parent's baby workspace" do
    travel_to Time.zone.local(2026, 3, 24, 9, 0) do
      owner = users(:one)
      partner = users(:two)
      baby = create_baby_for(owner)
      BabyMembership.create!(baby: baby, user: partner, role: "parent")

      sign_in_as(owner)

      assert_difference -> { NextFeedReminder.count }, 1 do
        post next_feed_reminder_path, params: {
          next_feed_reminder: { target_at: "2026-03-24T10:30" }
        }
      end

      assert_redirected_to today_path
      assert_equal Time.zone.local(2026, 3, 24, 10, 30), baby.reload.next_feed_reminder.target_at

      delete session_path
      sign_in_as(partner)
      get today_path

      assert_response :success
      assert_match "Feed reminder", response.body
      assert_match "Set for 10:30 AM", response.body
      assert_match "in 1 hr 30 min", response.body
    end
  end

  test "updating the reminder replaces the previous time instead of creating duplicates" do
    travel_to Time.zone.local(2026, 3, 24, 9, 0) do
      owner = users(:one)
      baby = create_baby_for(owner)
      reminder = baby.create_next_feed_reminder!(target_at: Time.zone.local(2026, 3, 24, 10, 0))

      sign_in_as(owner)

      assert_no_difference -> { NextFeedReminder.count } do
        patch next_feed_reminder_path, params: {
          next_feed_reminder: { target_at: "2026-03-24T11:15" }
        }
      end

      assert_redirected_to today_path
      assert_equal reminder.id, baby.reload.next_feed_reminder.id
      assert_equal Time.zone.local(2026, 3, 24, 11, 15), reminder.reload.target_at
    end
  end

  test "clearing the reminder removes the shared reminder state" do
    owner = users(:one)
    baby = create_baby_for(owner)
    baby.create_next_feed_reminder!(target_at: Time.zone.local(2026, 3, 24, 10, 0))

    sign_in_as(owner)

    assert_difference -> { NextFeedReminder.count }, -1 do
      delete next_feed_reminder_path
    end

    assert_redirected_to today_path
    follow_redirect!
    assert_match "Next feed reminder cleared.", response.body
    assert_match "No feed reminder set", response.body
  end

  test "reminder access remains scoped to the correct baby workspace" do
    travel_to Time.zone.local(2026, 3, 24, 9, 0) do
      owner = users(:one)
      outsider = users(:invite_owner)
      owner_baby = create_baby_for(owner, first_name: "Milo")
      outsider_baby = create_baby_for(outsider, first_name: "Ivy")
      outsider_baby.create_next_feed_reminder!(target_at: Time.zone.local(2026, 3, 24, 12, 0))

      sign_in_as(owner)

      get today_path

      assert_response :success
      assert_match "No feed reminder set", response.body
      assert_no_match "12:00 PM", response.body

      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T10:45" }
      }

      assert_redirected_to today_path
      assert_equal Time.zone.local(2026, 3, 24, 10, 45), owner_baby.reload.next_feed_reminder.target_at
      assert_equal Time.zone.local(2026, 3, 24, 12, 0), outsider_baby.reload.next_feed_reminder.target_at
    end
  end

  test "today renders the empty reminder card with quick presets and exact time entry" do
    owner = users(:one)
    create_baby_for(owner)

    sign_in_as(owner)
    get today_path

    assert_response :success
    assert_match "No feed reminder set", response.body
    assert_match "Quick presets", response.body
    assert_match "30 min", response.body
    assert_match "1 hour", response.body
    assert_match "2 hours", response.body
    assert_match "3 hours", response.body
    assert_match "Exact time", response.body
    assert_select "input[type='datetime-local'][name='next_feed_reminder[target_at]']", 1
  end

  test "quick presets schedule from submission time instead of page render time" do
    owner = users(:one)
    baby = create_baby_for(owner)

    sign_in_as(owner)

    travel_to Time.zone.local(2026, 3, 24, 9, 0) do
      get today_path
    end

    travel_to Time.zone.local(2026, 3, 24, 9, 10) do
      post next_feed_reminder_path, params: { preset_minutes: 30 }
    end

    assert_redirected_to today_path
    assert_equal Time.zone.local(2026, 3, 24, 9, 40), baby.reload.next_feed_reminder.target_at
  end

  test "today renders the active reminder card state" do
    travel_to Time.zone.local(2026, 3, 24, 15, 45) do
      owner = users(:one)
      baby = create_baby_for(owner)
      baby.create_next_feed_reminder!(target_at: Time.zone.local(2026, 3, 24, 16, 30))

      sign_in_as(owner)
      get today_path

      assert_response :success
      assert_match "Feed reminder", response.body
      assert_match "Set for 4:30 PM", response.body
      assert_match "in 45 min", response.body
      assert_match "Edit reminder", response.body
      assert_match "Clear reminder", response.body
    end
  end

  test "today renders the overdue reminder card state" do
    travel_to Time.zone.local(2026, 3, 24, 15, 45) do
      owner = users(:one)
      baby = create_baby_for(owner)
      baby.create_next_feed_reminder!(target_at: Time.zone.local(2026, 3, 24, 15, 0))

      sign_in_as(owner)
      get today_path

      assert_response :success
      assert_match "Feed reminder", response.body
      assert_match "Set for 3:00 PM", response.body
      assert_match "45 min ago", response.body
      assert_no_match "Overdue", response.body
    end
  end

  test "invalid reminder submission renders Today with guidance and sleep state" do
    travel_to Time.zone.local(2026, 3, 26, 8, 0) do
      owner = users(:one)
      baby = create_baby_for(owner, first_name: "Milo")

      sign_in_as(owner)

      # Post with blank target_at (should fail validation)
      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "" }
      }

      assert_response :unprocessable_entity
      # Verify guidance notes are rendered (Phase 3 regression check)
      assert_match "At this age", response.body
      assert_match "Breastfed babies typically feed 10-12 times per 24 hours", response.body
      # Verify sleep state vars don't crash
      assert_match "Last sleep", response.body
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
