require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
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
end
