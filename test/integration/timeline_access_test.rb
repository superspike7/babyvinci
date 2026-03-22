require "test_helper"

class TimelineAccessTest < ActionDispatch::IntegrationTest
  test "signed in parent without a baby is sent to baby setup from timeline" do
    user = users(:one)

    post session_path, params: { email: user.email, password: "password" }
    get timeline_path
    follow_redirect!

    assert_response :success
    assert_equal new_baby_path, request.path
  end
end
