require "application_system_test_case"

class FeedLoggingTest < ApplicationSystemTestCase
  test "parent logs a feed from today" do
    user = User.create!(name: "Feed Parent", email: "feed-parent@example.com", password: "password123", password_confirmation: "password123")
    BabyCreator.create!(user: user, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))

    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Sign in"

    click_on "Feed"

    assert_text "Log feed"
    choose "Formula"
    fill_in "Amount (ml)", with: "75"
    click_on "Save feed"

    assert_current_path today_path
    assert_text "Feed logged"
    assert_text "Formula, 75 ml"
  end
end
