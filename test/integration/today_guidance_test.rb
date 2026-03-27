require "test_helper"

class TodayGuidanceTest < ActionDispatch::IntegrationTest
  test "today shows guidance notes for newborn baby" do
    travel_to Time.zone.local(2026, 3, 26, 8, 0) do
      user = users(:one)
      BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 24, 8, 0) # 2 days old
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_match "DAY 3", response.body
      assert_match "2 days old", response.body
      assert_match "At this age", response.body
      assert_match "Breastfed babies typically feed 10-12 times per 24 hours", response.body
      assert_match "Newborns sleep about 16-17 hours per day", response.body
    end
  end

  test "today shows guidance notes for 6-week-old baby" do
    travel_to Time.zone.local(2026, 4, 9, 8, 0) do
      user = users(:one)
      BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 2, 25, 3, 45) # 43 days old (6 weeks + 1 day)
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_match "At this age", response.body
      assert_match "Around 6 weeks", response.body
      assert_match "growth spurt", response.body
    end
  end

  test "today shows no more than 2 guidance notes" do
    travel_to Time.zone.local(2026, 3, 26, 8, 0) do
      user = users(:one)
      BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 24, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      # Count occurrences of "At this age" section content
      at_this_age_count = response.body.scan("At this age").size
      assert_equal 1, at_this_age_count, "Should only show one 'At this age' section"
    end
  end

  test "today shows no guidance for baby older than defined buckets" do
    travel_to Time.zone.local(2026, 10, 1, 8, 0) do
      user = users(:one)
      BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 2, 1, 3, 45) # ~8 months old
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      assert_response :success
      assert_no_match "At this age", response.body
    end
  end

  test "today shows different guidance for different age buckets" do
    travel_to Time.zone.local(2026, 3, 26, 8, 0) do
      user = users(:one)

      # Create 3-day-old baby (newborn)
      baby = BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 23, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }
      follow_redirect!

      # Check for newborn-specific guidance
      assert_match "Breastfed babies typically feed 10-12 times per 24 hours", response.body
      assert_no_match "cluster feeding", response.body.downcase
    end
  end
end
