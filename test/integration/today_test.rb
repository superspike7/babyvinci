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
      assert_match "Day 4", response.body
      assert_match "Last feed", response.body
      assert_match "Last diaper", response.body
      assert_match "No feed yet", response.body
      assert_match "No diaper yet", response.body
      assert_match "Recent activity", response.body
      assert_match "Nothing logged yet", response.body
      assert_match 'href="/feeds/new"', response.body
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
      assert_match "Formula, 90 ml", response.body
      assert_match "Logged by One Parent", response.body
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
      assert_match "Open timeline", response.body
      assert_match 'href="/timeline"', response.body
      assert_equal 8, response.body.scan("Logged by One Parent").size
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
      last_feed_section = response.body[/Last feed.*?<\/article>/m]

      assert_not_nil last_feed_section
      assert_match "about 4 hours ago", last_feed_section
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

      last_feed_section = response.body[/Last feed.*?<\/article>/m]

      assert_not_nil last_feed_section
      assert_match "about 5 hours ago", last_feed_section
      assert_no_match "about 9 hours", last_feed_section
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
