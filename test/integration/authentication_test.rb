require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "parent can sign up, create a baby, sign out, and sign back in" do
    post users_path, params: {
      user: {
        name: "Alex Parent",
        email: "alex@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_baby_path
    follow_redirect!

    assert_response :success
    assert_match "Create your baby's profile", response.body
    assert_match "Alex Parent", response.body

    post babies_path, params: {
      baby: {
        first_name: "Milo",
        birth_date: "2026-03-20",
        birth_time: "03:45"
      }
    }

    assert_redirected_to today_path
    follow_redirect!
    assert_response :success
    assert_match "Milo", response.body

    delete session_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_match "Signed out", response.body

    post session_path, params: { email: "alex@example.com", password: "password123" }
    assert_redirected_to today_path
    follow_redirect!
    assert_match "Milo", response.body
  end

  test "parent sees a helpful error for bad credentials" do
    User.create!(name: "Alex Parent", email: "alex@example.com", password: "password123", password_confirmation: "password123")

    post session_path, params: { email: "alex@example.com", password: "wrong-password" }

    assert_redirected_to new_session_path
    follow_redirect!

    assert_response :success
    assert_match "Try another email or password.", response.body
    assert_equal new_session_path, request.path
  end

  test "parent can sign in with a normalized email" do
    User.create!(name: "Alex Parent", email: "alex@example.com", password: "password123", password_confirmation: "password123")

    post session_path, params: { email: "  Alex@Example.com ", password: "password123" }

    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_baby_path
    follow_redirect!

    assert_response :success
    assert_match "Create your baby's profile", response.body
    assert_match "Alex Parent", response.body
  end
end
