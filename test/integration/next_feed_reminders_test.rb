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
      assert_match "Next feed reminder", response.body
      assert_match "10:30 AM", response.body
      assert_match "Due in about 2 hours", response.body
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
    assert_match "No reminder set yet.", response.body
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
      assert_match "No reminder set yet.", response.body
      assert_no_match "12:00 PM", response.body

      post next_feed_reminder_path, params: {
        next_feed_reminder: { target_at: "2026-03-24T10:45" }
      }

      assert_redirected_to today_path
      assert_equal Time.zone.local(2026, 3, 24, 10, 45), owner_baby.reload.next_feed_reminder.target_at
      assert_equal Time.zone.local(2026, 3, 24, 12, 0), outsider_baby.reload.next_feed_reminder.target_at
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
