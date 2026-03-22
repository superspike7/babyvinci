require "application_system_test_case"

class TimelineNavigationTest < ApplicationSystemTestCase
  test "parent can open timeline from today and return to today" do
    user = User.create!(name: "Timeline Parent", email: "timeline-nav@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: user, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))

    CareEvent.create!(baby: baby, user: user, kind: "feed", started_at: Time.zone.local(2026, 3, 23, 7, 30), payload: { "mode" => "formula", "amount_ml" => 80 })
    CareEvent.create!(baby: baby, user: user, kind: "diaper", started_at: Time.zone.local(2026, 3, 23, 6, 50), payload: { "pee" => true, "poop" => true })

    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Sign in"

    assert_text "Today"
    assert_link "Open timeline"

    click_on "Open timeline"

    assert_text "Monday, March 23"
    assert_text "Formula, 80 ml"
    assert_text "Wet + stool"
    assert_link "Back to today"

    click_on "Back to today"

    assert_current_path today_path
    assert_link "Open timeline"
    assert_text "Formula, 80 ml"
  end
end
