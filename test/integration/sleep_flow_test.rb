require "test_helper"

class SleepFlowTest < ActionDispatch::IntegrationTest
  test "parent can start sleep from today page" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get today_path
    assert_response :success
    assert_select "a", text: /Sleep/i

    get new_sleep_path
    assert_response :success
    assert_select "h1", text: /Start sleep/i

    post sleeps_path, params: {
      care_event: {
        started_at: Time.zone.now.change(sec: 0).strftime("%Y-%m-%dT%H:%M")
      }
    }

    assert_redirected_to today_path
    follow_redirect!

    assert_response :success
    assert_select "p", text: /Sleeping now/i
    assert_select "button", text: /End sleep/i
  end

  test "parent can end sleep from today page" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 1.hour.ago,
      payload: {}
    )

    sign_in_as(users(:one))

    get today_path
    assert_response :success
    assert_select "p", text: /Sleeping now/i

    post end_sleep_sleeps_path
    assert_redirected_to today_path
    follow_redirect!

    assert_response :success
    assert_select "p", text: /Last sleep/i
  end

  test "cannot start sleep when one is already active" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 1.hour.ago,
      payload: {}
    )

    sign_in_as(users(:one))

    post sleeps_path, params: {
      care_event: {
        started_at: Time.zone.now.change(sec: 0).strftime("%Y-%m-%dT%H:%M")
      }
    }

    assert_response :unprocessable_entity
  end

  test "sleep appears in timeline after ending" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 2.hours.ago,
      payload: {}
    )

    sleep.update!(ended_at: 30.minutes.ago)

    sign_in_as(users(:one))

    get timeline_path
    assert_response :success
    assert_select "p", text: /Sleep/i
  end

  private
    def sign_in_as(user)
      post session_path, params: { email: user.email, password: "password" }
      assert_redirected_to today_path
    end
end
