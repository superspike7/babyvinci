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
      assert_match ">Feed<", response.body
      assert_match ">Diaper<", response.body
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
