require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "parent can sign up and sign back in" do
    visit root_path

    assert_text "Sign in"
    click_on "Create account"

    fill_in "Name", with: "Alex Parent"
    fill_in "Email", with: "alex@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm password", with: "password123"
    click_on "Create account"

    assert_text "You're signed in"
    assert_text "Alex Parent"

    click_on "Sign out"

    assert_text "Signed out"
    fill_in "Email", with: "alex@example.com"
    fill_in "Password", with: "password123"
    click_on "Sign in"

    assert_text "You're signed in"
  end

  test "parent sees a helpful error for bad credentials" do
    User.create!(name: "Alex Parent", email: "alex@example.com", password: "password123", password_confirmation: "password123")

    visit new_session_path

    fill_in "Email", with: "alex@example.com"
    fill_in "Password", with: "wrong-password"
    click_on "Sign in"

    assert_text "Try another email or password."
    assert_current_path new_session_path
  end

  test "parent can sign in with a normalized email" do
    User.create!(name: "Alex Parent", email: "alex@example.com", password: "password123", password_confirmation: "password123")

    visit new_session_path

    fill_in "Email", with: "  Alex@Example.com "
    fill_in "Password", with: "password123"
    click_on "Sign in"

    assert_text "You're signed in"
  end
end
