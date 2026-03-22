require "test_helper"

class TimelineTest < ActionDispatch::IntegrationTest
  test "signed in parent sees shared events grouped newest first" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      parent_a = users(:one)
      parent_b = users(:two)
      baby = BabyCreator.create!(
        user: parent_a,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )
      baby.users << parent_b

      CareEvent.create!(
        baby: baby,
        user: parent_a,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 7, 30),
        payload: { "mode" => "formula", "amount_ml" => 80 }
      )
      CareEvent.create!(
        baby: baby,
        user: parent_b,
        kind: "diaper",
        started_at: Time.zone.local(2026, 3, 23, 6, 50),
        payload: { "pee" => true, "poop" => true }
      )
      CareEvent.create!(
        baby: baby,
        user: parent_a,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 22, 23, 15),
        payload: { "mode" => "breast", "side" => "left", "duration_min" => 14 }
      )

      post session_path, params: { email: parent_b.email, password: "password" }
      get timeline_path

      assert_response :success
      assert_match "Timeline", response.body
      assert_match "Shared log", response.body
      assert_match "Monday, March 23", response.body
      assert_match "Sunday, March 22", response.body
      assert_operator response.body.index("Formula, 80 ml"), :<, response.body.index("Wet + stool")
      assert_match "Logged by One Parent", response.body
      assert_match "Logged by Two Parent", response.body
      assert_match "7:30", response.body
      assert_match "6:50", response.body
    end
  end

  test "timeline only shows events for the current baby workspace" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      parent = users(:one)
      visible_baby = BabyCreator.create!(
        user: parent,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )
      hidden_parent = User.create!(name: "Hidden Parent", email: "hidden@example.com", password: "password")
      hidden_baby = BabyCreator.create!(
        user: hidden_parent,
        first_name: "Ivy",
        birth_at: Time.zone.local(2026, 3, 21, 5, 0)
      )

      CareEvent.create!(
        baby: visible_baby,
        user: parent,
        kind: "feed",
        started_at: Time.zone.local(2026, 3, 23, 7, 30),
        payload: { "mode" => "formula" }
      )
      CareEvent.create!(
        baby: hidden_baby,
        user: hidden_parent,
        kind: "diaper",
        started_at: Time.zone.local(2026, 3, 23, 7, 40),
        payload: { "pee" => true }
      )

      post session_path, params: { email: parent.email, password: "password" }
      get timeline_path

      assert_response :success
      assert_match "Formula", response.body
      assert_no_match "Logged by Hidden Parent", response.body
    end
  end

  test "parent can open timeline from today and return to today" do
    travel_to Time.zone.local(2026, 3, 23, 8, 0) do
      user = User.create!(name: "Timeline Parent", email: "timeline-nav@example.com", password: "password123", password_confirmation: "password123")
      baby = BabyCreator.create!(user: user, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))

      CareEvent.create!(baby: baby, user: user, kind: "feed", started_at: Time.zone.local(2026, 3, 23, 7, 30), payload: { "mode" => "formula", "amount_ml" => 80 })
      CareEvent.create!(baby: baby, user: user, kind: "diaper", started_at: Time.zone.local(2026, 3, 23, 6, 50), payload: { "pee" => true, "poop" => true })

      post session_path, params: { email: user.email, password: "password123" }
      follow_redirect!

      assert_response :success
      assert_equal today_path, request.path
      assert_match "Today", response.body
      assert_match "Open timeline", response.body
      assert_match "Formula, 80 ml", response.body
      assert_match 'href="/timeline"', response.body

      get timeline_path

      assert_response :success
      assert_match "Monday, March 23", response.body
      assert_match "Formula, 80 ml", response.body
      assert_match "Wet + stool", response.body
      assert_match "Back to today", response.body
      assert_match 'href="/today"', response.body

      get today_path

      assert_response :success
      assert_match "Open timeline", response.body
      assert_match "Formula, 80 ml", response.body
    end
  end
end
