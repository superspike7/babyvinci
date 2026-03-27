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

  test "parent can edit a completed sleep from today and return to today" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      baby = BabyCreator.create!(
        user: users(:one),
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      sleep = CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 6, 45),
        ended_at: Time.zone.local(2026, 3, 23, 7, 15),
        payload: {}
      )

      sign_in_as(users(:one))

      get today_path
      assert_response :success
      assert_includes response.body, edit_care_event_path(sleep, return_to: today_path)

      get edit_care_event_path(sleep), params: { return_to: today_path }

      assert_response :success
      assert_match "Edit sleep", response.body
      assert_match "Delete sleep", response.body

      patch care_event_path(sleep), params: {
        return_to: today_path,
        care_event: {
          started_at: "2026-03-23T06:30",
          ended_at: "2026-03-23T07:20"
        }
      }

      assert_redirected_to today_path
      follow_redirect!

      assert_match "Sleep updated", response.body
      assert_match "50 min", response.body
      assert_equal Time.zone.local(2026, 3, 23, 6, 30), sleep.reload.started_at
      assert_equal Time.zone.local(2026, 3, 23, 7, 20), sleep.ended_at
    end
  end

  test "parent can edit an active sleep start time and delete it" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      baby = BabyCreator.create!(
        user: users(:one),
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      sleep = CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 7, 30),
        payload: {}
      )

      sign_in_as(users(:one))

      get today_path
      assert_response :success
      assert_includes response.body, edit_care_event_path(sleep, return_to: today_path)

      get edit_care_event_path(sleep)

      assert_response :success
      assert_match "Edit sleep", response.body
      assert_match "Adjust when this sleep started", response.body
      assert_select "input[name='care_event[started_at]']"
      assert_select "input[name='care_event[ended_at]']", false
      assert_match "Delete sleep", response.body

      patch care_event_path(sleep), params: {
        care_event: {
          started_at: "2026-03-23T07:15",
          ended_at: "2026-03-23T07:50"
        }
      }

      assert_redirected_to timeline_path
      assert_equal Time.zone.local(2026, 3, 23, 7, 15), sleep.reload.started_at
      assert_nil sleep.ended_at

      assert_difference -> { baby.care_events.count }, -1 do
        delete care_event_path(sleep)
      end

      assert_redirected_to timeline_path
      follow_redirect!
      assert_match "Sleep deleted", response.body
      assert_no_match "Sleeping now", response.body
    end
  end

  test "parent can delete a completed sleep from the edit page" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      baby = BabyCreator.create!(
        user: users(:one),
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      sleep = CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 6, 45),
        ended_at: Time.zone.local(2026, 3, 23, 7, 15),
        payload: {}
      )

      sign_in_as(users(:one))

      assert_difference -> { baby.care_events.count }, -1 do
        delete care_event_path(sleep), params: { return_to: today_path }
      end

      assert_redirected_to today_path
      follow_redirect!

      assert_match "Sleep deleted", response.body
      assert_match "None yet", response.body
    end
  end

  test "deleting an active sleep from today clears the active state" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      baby = BabyCreator.create!(
        user: users(:one),
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      sleep = CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 7, 15),
        payload: {}
      )

      sign_in_as(users(:one))

      assert_difference -> { baby.care_events.count }, -1 do
        delete care_event_path(sleep), params: { return_to: today_path }
      end

      assert_redirected_to today_path
      follow_redirect!

      assert_match "Sleep deleted", response.body
      assert_no_match "Sleeping now", response.body
      assert_no_match "End sleep", response.body
    end
  end

  test "deleting a completed sleep from timeline removes it from shared history" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      baby = BabyCreator.create!(
        user: users(:one),
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      sleep = CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 6, 45),
        ended_at: Time.zone.local(2026, 3, 23, 7, 15),
        payload: {}
      )

      sign_in_as(users(:one))

      assert_difference -> { baby.care_events.count }, -1 do
        delete care_event_path(sleep), params: { return_to: timeline_path }
      end

      assert_redirected_to timeline_path
      follow_redirect!

      assert_match "Sleep deleted", response.body
      assert_no_match "45 min", response.body
      assert_no_match "6:45 AM", response.body
    end
  end

  test "sleep edit with blank start time shows validation instead of defaulting to now" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      baby = BabyCreator.create!(
        user: users(:one),
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      sleep = CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 6, 45),
        ended_at: Time.zone.local(2026, 3, 23, 7, 15),
        payload: {}
      )

      sign_in_as(users(:one))

      patch care_event_path(sleep), params: {
        care_event: {
          started_at: "",
          ended_at: "2026-03-23T07:20"
        }
      }

      assert_response :unprocessable_entity
      assert_match "Started at can&#39;t be blank", response.body
      assert_equal Time.zone.local(2026, 3, 23, 6, 45), sleep.reload.started_at
      assert_equal Time.zone.local(2026, 3, 23, 7, 15), sleep.ended_at
    end
  end

  test "timeline shows edit link for completed and active sleeps" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "feed",
      started_at: 1.hour.ago,
      payload: { "mode" => "formula" }
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 2.hours.ago,
      payload: {}
    )
    sleep.update!(ended_at: 90.minutes.ago)

    active_sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 10.minutes.ago,
      payload: {}
    )

    sign_in_as(users(:one))

    get timeline_path
    assert_response :success
    # Feed should have Edit link (use for_kind scope)
    feed_event = baby.care_events.for_kind("feed").first
    assert_select "a[href=?]", edit_care_event_path(feed_event, return_to: timeline_path), text: "Edit"
    assert_select "a[href=?]", edit_care_event_path(sleep, return_to: timeline_path), text: "Edit"
    assert_select "a[href=?]", edit_care_event_path(active_sleep, return_to: timeline_path), text: "Edit"
  end

  private
    def sign_in_as(user)
      post session_path, params: { email: user.email, password: "password" }
      assert_redirected_to today_path
    end
end
