require "test_helper"

class MobileLayoutTest < ActionDispatch::IntegrationTest
  test "today timeline and more expose mobile-first navigation and quick actions" do
    user = sign_in_parent_with_baby!

    get today_path

    assert_response :success
    assert_includes response.body, 'href="/today"'
    assert_includes response.body, 'href="/timeline"'
    assert_includes response.body, 'href="/more"'
    assert_includes response.body, 'href="/feeds/new"'
    assert_includes response.body, 'href="/diapers/new"'

    get timeline_path

    assert_response :success
    assert_includes response.body, 'href="/today"'
    assert_includes response.body, 'href="/timeline"'
    assert_includes response.body, 'href="/more"'
    assert_includes response.body, 'href="/feeds/new"'
    assert_includes response.body, 'href="/diapers/new"'
    assert_no_match(/disabled[^>]*>Diaper</, response.body)

    get more_path

    assert_response :success
    assert_match "More", response.body
    assert_match "Invite family member", response.body
    assert_match "Sign out", response.body
    assert_includes response.body, 'href="/feeds/new"'
    assert_includes response.body, 'href="/diapers/new"'
  end

  test "feed diaper and invite routes keep primary navigation available on mobile" do
    sign_in_parent_with_baby!

    get new_feed_path

    assert_response :success
    assert_match "Log feed", response.body
    assert_includes response.body, 'href="/today"'
    assert_includes response.body, 'href="/timeline"'
    assert_includes response.body, 'href="/more"'
    assert_match "Save feed", response.body

    get new_diaper_path

    assert_response :success
    assert_match "Log diaper", response.body
    assert_includes response.body, 'href="/today"'
    assert_includes response.body, 'href="/timeline"'
    assert_includes response.body, 'href="/more"'
    assert_match "Save diaper", response.body

    get new_baby_invite_path

    assert_response :success
    assert_match "Invite family member", response.body
    assert_includes response.body, 'href="/today"'
    assert_includes response.body, 'href="/timeline"'
    assert_includes response.body, 'href="/more"'
    assert_match "Create invite", response.body
  end

  test "more page shows current invite details when an invite is active" do
    user = sign_in_parent_with_baby!
    baby = user.babies.first
    invite = baby.baby_invites.create!(email: "partner@example.com", invited_by_user: user, expires_at: 3.days.from_now)

    get more_path

    assert_response :success
    assert_match "Invite ready for partner@example.com", response.body
    assert_includes response.body, baby_invite_path(invite)
  end

  test "more page shows the full-seat state when three members already joined" do
    user = sign_in_parent_with_baby!
    baby = user.babies.first
    baby.baby_memberships.create!(user: users(:two), role: "parent")
    extra_user = User.create!(name: "Third Member", email: "third-mobile@example.com", password: "password123", password_confirmation: "password123")
    baby.baby_memberships.create!(user: extra_user, role: "parent")

    get more_path

    assert_response :success
    assert_match "Shared access is full.", response.body
    assert_no_match "Invite family member", response.body
  end

  private
    def sign_in_parent_with_baby!
      user = users(:one)
      BabyCreator.create!(
        user: user,
        first_name: "Milo",
        birth_at: Time.zone.local(2026, 3, 20, 3, 45)
      )

      post session_path, params: { email: user.email, password: "password" }

      user
    end
end
