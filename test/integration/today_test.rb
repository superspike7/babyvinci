require "test_helper"

class TodayTest < ActionDispatch::IntegrationTest
  test "signed in parent sees the today dashboard" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_equal today_path, request.path
      assert_match "Today", response.body
      assert_match "Milo", response.body
      assert_match "DAY 4", response.body
      assert_match "Feeds", response.body
      assert_match "Wet", response.body
      assert_match "Stool", response.body
      assert_match "Sleep", response.body
      assert_match "Last feed", response.body
      assert_match "Last diaper", response.body
      assert_match "No feed yet", response.body
      assert_match "No diaper yet", response.body
      assert_match "Today is still quiet", response.body
      assert_match "No feed reminder set", response.body
      assert_match "Recent activity", response.body
      assert_match "Nothing logged yet", response.body
      assert_match 'href="/feeds/new"', response.body
      assert_match 'href="/diapers/new"', response.body
      assert_match ">Feed<", response.body
      assert_match ">Diaper<", response.body
    end
  end

  test "parent can log a feed and return to today with updated summaries" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }

      assert_difference -> { baby.care_events.for_kind("feed").count }, 1 do
        post feeds_path, params: {
          care_event: {
            started_at: "2026-03-23T07:54",
            mode: "formula",
            amount_ml: "90",
            side: "",
            duration_min: ""
          }
        }
      end

      assert_redirected_to today_path
      follow_redirect!

      assert_match "Feed logged", response.body
      assert_match "6 minutes ago", response.body
      assert_match "7:54 AM", response.body
      assert_match "Formula, 90 ml", response.body
      assert_match ">Today</p>", response.body
      assert_match "Logged by One Parent", response.body
    end
  end

  test "parent can log a diaper and return to today with updated summaries" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }

      assert_difference -> { baby.care_events.for_kind("diaper").count }, 1 do
        post diapers_path, params: {
          care_event: {
            started_at: "2026-03-23T07:54",
            diaper_type: "both",
            color: "Yellow"
          }
        }
      end

      assert_redirected_to today_path
      follow_redirect!

      assert_match "Diaper logged", response.body
      assert_match "6 minutes ago", response.body
      assert_match "7:54 AM", response.body
      assert_match "Wet \+ stool, Yellow", response.body
      assert_match "1W · 1S", response.body
      assert_match "Logged by One Parent", response.body
    end
  end

  test "wet diaper ignores poop color note" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }

      post diapers_path, params: {
        care_event: {
          started_at: "2026-03-23T07:54",
          diaper_type: "wet",
          color: "Yellow"
        }
      }

      assert_redirected_to today_path
      assert_equal(
        { "pee" => true, "poop" => false },
        baby.care_events.for_kind("diaper").order(:id).last.payload
      )

      follow_redirect!
      assert_no_match "Wet, Yellow", response.body
    end
  end

  test "today shows the latest summaries, recent events, and timeline entry point" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      9.times do |index|
        CareEvent.create!(
          baby: baby,
          user: user,
          kind: index.even? ? "feed" : "diaper",
          started_at: Time.zone.local(2026, 3, 23, 7, 59 - index),
          payload: index.even? ? { "mode" => "formula", "amount_ml" => 60 + index } : { "pee" => true, "poop" => index == 1 }
        )
      end

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_equal today_path, request.path
      assert_match "1 minute ago", response.body
      assert_match "2 minutes ago", response.body
      assert_match "Formula, 60 ml", response.body
      assert_match "Wet + stool", response.body
      assert_match "4W · 1S", response.body
      assert_match "Open timeline", response.body
      assert_match 'href="/timeline"', response.body
      assert_equal 5, response.body.scan("Logged by One Parent").size
      assert_no_match "Formula, 68 ml", response.body
    end
  end

  test "today last feed uses latest started_at not latest created_at" do
    travel_to Time.zone.local(2026, 3, 23, 3, 15) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      latest_by_started_at = CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 22, 23, 0),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )
      saved_later = CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 22, 13, 30),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )

      latest_by_started_at.update_columns(created_at: Time.zone.local(2026, 3, 23, 3, 5), updated_at: Time.zone.local(2026, 3, 23, 3, 5))
      saved_later.update_columns(created_at: Time.zone.local(2026, 3, 23, 3, 10), updated_at: Time.zone.local(2026, 3, 23, 3, 10))

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      last_feed_section = response.body[/Last feed.*?Last diaper/m]

      assert_not_nil last_feed_section
      assert_match "11:00 PM", last_feed_section
      assert_match "4h 15m", last_feed_section
    end
  end

  test "today last feed ignores future-dated feeds" do
    travel_to Time.zone.local(2026, 3, 23, 4, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 22, 23, 0),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 13, 30),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      last_feed_section = response.body[/Last feed.*?Last diaper/m]

      assert_not_nil last_feed_section
      assert_match "11:00 PM", last_feed_section
      assert_match "5h", last_feed_section
      assert_no_match "1:30 PM", last_feed_section
    end
  end

  test "today recent activity and last diaper ignore future-dated events" do
    travel_to Time.zone.local(2026, 3, 23, 4, 22) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Vinci",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 22, 23, 0),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "diaper",
        started_at: Time.zone.local(2026, 3, 22, 23, 30),
        payload: { "pee" => true, "poop" => true }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "diaper",
        started_at: Time.zone.local(2026, 3, 23, 4, 45),
        payload: { "pee" => true, "poop" => true }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 13, 30),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success

      last_diaper_section = response.body[/Last diaper.*?(?:Last sleep|Concerned\?)/m]
      recent_activity_section = response.body[/Recent activity.*?<\/section>/m]

      assert_not_nil last_diaper_section
      assert_not_nil recent_activity_section
      assert_match "11:30 PM", last_diaper_section
      assert_match "4h 52m", last_diaper_section
      assert_no_match "No diaper yet", last_diaper_section
      assert_match "11:30 PM", recent_activity_section
      assert_match "11:00 PM", recent_activity_section
      assert_not_includes recent_activity_section, "4:30 AM"
      assert_equal 2, recent_activity_section.scan("Logged by One Parent").size
    end
  end

  test "parent can edit a recent feed from today and return to today" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      feed = CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 7, 54),
        payload: { "mode" => "formula", "amount_ml" => 90 }
      )

      post session_path, params: { email: user.email, password: "password" }
      get today_path

      assert_response :success
      assert_match "Edit", response.body
      assert_includes response.body, edit_care_event_path(feed, return_to: today_path)

      get edit_care_event_path(feed), params: { return_to: today_path }

      assert_response :success
      assert_match "Edit feed", response.body
      assert_match "Delete feed", response.body

      patch care_event_path(feed), params: {
        return_to: today_path,
        care_event: {
          started_at: "2026-03-23T07:50",
          mode: "breast",
          amount_ml: "",
          side: "left",
          duration_min: "12"
        }
      }

      assert_redirected_to today_path
      follow_redirect!

      assert_match "Feed updated", response.body
      assert_match "10 minutes ago", response.body
      assert_match "Breast, 12 min", response.body
      assert_equal "breast", feed.reload.feed_mode
      assert_equal "left", feed.feed_side
      assert_equal 12, feed.feed_duration_min
    end
  end

  test "today shows a near-future diaper as just now but still hides later events" do
    travel_to Time.zone.local(2026, 3, 23, 4, 22) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Vinci",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "diaper",
        started_at: Time.zone.local(2026, 3, 23, 4, 30),
        payload: { "pee" => true, "poop" => true }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 13, 30),
        payload: { "mode" => "formula", "amount_ml" => 30 }
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success

      last_diaper_section = response.body[/Last diaper.*?(?:Last sleep|Concerned\?)/m]
      recent_activity_section = response.body[/Recent activity.*?<\/section>/m]

      assert_not_nil last_diaper_section
      assert_not_nil recent_activity_section
      assert_match "4:30 AM", last_diaper_section
      assert_match "just now", last_diaper_section
      assert_match "Wet \+ stool", last_diaper_section
      assert_match "Diaper", recent_activity_section
      assert_match "4:30 AM", recent_activity_section
      assert_match "just now", recent_activity_section
      assert_not_includes recent_activity_section, "1:30 PM"
    end
  end

  test "today shows soft feed guidance when the last feed is getting stale" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 5, 55),
        payload: { "mode" => "formula", "amount_ml" => 75 }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "diaper",
        started_at: Time.zone.local(2026, 3, 23, 6, 40),
        payload: { "pee" => true, "poop" => false }
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_match "Feed likely soon", response.body
      assert_match "Last feed was 2 hr 5 min ago", response.body
      assert_match "1W · 0S", response.body
    end
  end

  test "today sleep total includes overnight sleep and active sleep overlap" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = users(:one)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 6, 0),
        payload: { "mode" => "breast", "duration_min" => 20 }
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 22, 23, 30),
        ended_at: Time.zone.local(2026, 3, 23, 1, 0),
        payload: {}
      )
      CareEvent.create!(
        baby: baby,
        user: user,
        kind: "sleep",
        started_at: Time.zone.local(2026, 3, 23, 6, 48),
        payload: {}
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_match "2h 12m", response.body
      assert_match "Sleeping for 1 hr 12 min", response.body
      assert_match "Last feed was 2 hr ago", response.body
      assert_match "End sleep", response.body
    end
  end

  test "signed in parent without a baby is sent to baby setup" do
    user = users(:one)

    post session_path, params: { email: user.email, password: "password" }
    follow_redirect!
    follow_redirect!

    assert_response :success
    assert_equal new_baby_path, request.path
  end
end
