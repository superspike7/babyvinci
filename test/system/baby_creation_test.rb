require "application_system_test_case"

class BabyCreationTest < ApplicationSystemTestCase
  test "signed in parent creates their baby profile before using the app" do
    visit new_session_path

    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password"
    click_on "Sign in"

    assert_text "Create your baby's profile"

    fill_in "Baby's first name", with: "Milo"
    fill_in "Birth date", with: Date.new(2026, 3, 20)
    fill_in "Birth time", with: "03:45"
    click_on "Save baby profile"

    assert_text "Baby profile ready."
    assert_text "Milo"
    assert_text "One Parent"
  end

  test "parent sees validation errors when baby details are incomplete" do
    visit new_session_path

    fill_in "Email", with: users(:one).email
    fill_in "Password", with: "password"
    click_on "Sign in"

    click_on "Save baby profile"

    assert_text "First name can't be blank"
  end
end
