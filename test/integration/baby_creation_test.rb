require "test_helper"

class BabyCreationTest < ActionDispatch::IntegrationTest
  test "signed in parent creates their baby profile before using the app" do
    user = User.create!(name: "Baby Setup Parent", email: "baby-setup@example.com", password: "password123", password_confirmation: "password123")

    post session_path, params: { email: user.email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_baby_path
    follow_redirect!

    assert_response :success
    assert_match "Create your baby's profile", response.body

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
    assert_match "Baby profile ready.", response.body
    assert_match "Milo", response.body
    assert_match "Today", response.body
  end

  test "parent sees validation errors when baby details are incomplete" do
    user = User.create!(name: "Validation Parent", email: "validation@example.com", password: "password123", password_confirmation: "password123")

    post session_path, params: { email: user.email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to new_baby_path

    post babies_path, params: {
      baby: {
        first_name: "",
        birth_date: "",
        birth_time: ""
      }
    }

    assert_response :unprocessable_entity
    assert_match "First name can&#39;t be blank", response.body
    assert_match "Birth at can&#39;t be blank", response.body
  end
end
