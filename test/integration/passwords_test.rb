require "test_helper"

class PasswordsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "reset request normalizes the submitted email" do
    user = User.create!(name: "Alex Parent", email: "alex@example.com", password: "password123", password_confirmation: "password123")

    assert_emails 1 do
      perform_enqueued_jobs do
        post passwords_path, params: { email: "  Alex@Example.com " }
      end
    end

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent if that account exists.", flash[:notice]
    assert_equal user.email, PasswordsMailer.deliveries.last.to.first
  end

  test "resetting a password revokes existing sessions" do
    user = User.create!(name: "Alex Parent", email: "alex@example.com", password: "password123", password_confirmation: "password123")
    user.sessions.create!(ip_address: "127.0.0.1", user_agent: "test")

    patch password_path(user.password_reset_token), params: {
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }

    assert_redirected_to new_session_path
    assert_equal "Password has been reset.", flash[:notice]
    assert_equal 0, user.sessions.count
    assert User.authenticate_by(email: user.email, password: "newpassword123")
  end
end
