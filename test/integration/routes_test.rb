require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
  test "feed route serves the new feed page for signed in parents" do
    user = users(:one)
    BabyCreator.create!(
      user: user,
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    post session_path, params: { email: user.email, password: "password" }
    get new_feed_path

    assert_response :success
    assert_match "Log feed", response.body
  end

  test "diaper route serves the new diaper page for signed in parents" do
    user = users(:one)
    BabyCreator.create!(
      user: user,
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    post session_path, params: { email: user.email, password: "password" }
    get new_diaper_path

    assert_response :success
    assert_match "Log diaper", response.body
  end

  test "more route serves the shared access page for signed in parents" do
    user = users(:one)
    BabyCreator.create!(
      user: user,
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    post session_path, params: { email: user.email, password: "password" }
    get more_path

    assert_response :success
    assert_match "More", response.body
  end

  test "login alias serves the sign in page" do
    get login_path

    assert_response :success
    assert_match "Sign in", response.body
  end

  test "signup alias serves the create account page" do
    get signup_path

    assert_response :success
    assert_match "Create account", response.body
  end

  test "login page still loads for older mobile browsers" do
    get login_path, headers: {
      "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1"
    }

    assert_response :success
    assert_match "Sign in", response.body
  end
end
