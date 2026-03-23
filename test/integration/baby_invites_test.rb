require "test_helper"

class BabyInvitesTest < ActionDispatch::IntegrationTest
  test "eligible member can create an invite while the baby log has room" do
    parent = User.create!(name: "Invite Owner", email: "invite-owner@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: parent, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))

    post session_path, params: { email: parent.email, password: "password123" }

    assert_difference -> { BabyInvite.count }, 1 do
      post baby_invites_path, params: { baby_invite: { email: "partner@example.com" } }
    end

    invite = BabyInvite.order(:id).last

    assert_redirected_to baby_invite_path(invite)
    follow_redirect!

    assert_response :success
    assert_match "Invite family member", response.body
    assert_match "partner@example.com", response.body
    assert_match invite_url(invite.token), response.body
    assert_equal baby, invite.baby
    assert_equal parent, invite.invited_by_user
    assert invite.active?
  end

  test "workspace with three members cannot create a fourth invite" do
    parent_a = User.create!(name: "Parent A", email: "parent-a@example.com", password: "password123", password_confirmation: "password123")
    parent_b = User.create!(name: "Parent B", email: "parent-b@example.com", password: "password123", password_confirmation: "password123")
    parent_c = User.create!(name: "Parent C", email: "parent-c@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: parent_a, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))
    baby.baby_memberships.create!(user: parent_b, role: "parent")
    baby.baby_memberships.create!(user: parent_c, role: "parent")

    post session_path, params: { email: parent_a.email, password: "password123" }

    assert_no_difference -> { BabyInvite.count } do
      post baby_invites_path, params: { baby_invite: { email: "fourth@example.com" } }
    end

    assert_redirected_to today_path
    follow_redirect!

    assert_match "This baby log already has 3 people.", response.body
  end

  test "invited parent can create an account from the invite and join the baby workspace" do
    owner = User.create!(name: "Owner Parent", email: "owner@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: owner, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))
    CareEvent.create!(baby: baby, user: owner, kind: "feed", started_at: Time.zone.local(2026, 3, 23, 7, 30), payload: { "mode" => "formula" })
    invite = BabyInvite.create!(baby: baby, invited_by_user: owner, email: "partner@example.com", expires_at: 3.days.from_now)

    get invite_path(invite.token)

    assert_response :success
    assert_match "Join Milo&#39;s shared log", response.body
    assert_match "partner@example.com", response.body

    assert_difference [ -> { User.count }, -> { baby.users.count } ], 1 do
      post invite_acceptance_path(invite.token), params: {
        acceptance: {
          name: "Partner Parent",
          email: "partner@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to today_path
    follow_redirect!

    assert_response :success
    assert_match "You&#39;re in. Milo&#39;s shared log is ready.", response.body
    assert_match "Formula", response.body
    assert_equal [ owner, User.find_by!(email: "partner@example.com") ].sort_by(&:email), baby.users.order(:email).to_a
    assert_not invite.reload.active?
  end

  test "third member can join an existing two-member baby workspace" do
    owner = User.create!(name: "Owner Parent", email: "owner-three@example.com", password: "password123", password_confirmation: "password123")
    second_member = User.create!(name: "Second Member", email: "second@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: owner, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))
    baby.baby_memberships.create!(user: second_member, role: "parent")
    CareEvent.create!(baby: baby, user: owner, kind: "feed", started_at: Time.zone.local(2026, 3, 23, 7, 30), payload: { "mode" => "formula" })
    invite = BabyInvite.create!(baby: baby, invited_by_user: second_member, email: "third@example.com", expires_at: 3.days.from_now)

    assert_difference [ -> { User.count }, -> { baby.users.count } ], 1 do
      post invite_acceptance_path(invite.token), params: {
        acceptance: {
          name: "Third Member",
          email: "third@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to today_path
    follow_redirect!

    assert_response :success
    assert_match "You&#39;re in. Milo&#39;s shared log is ready.", response.body
    assert_match "Formula", response.body
    assert_equal [ "owner-three@example.com", "second@example.com", "third@example.com" ], baby.users.order(:email).pluck(:email)
    assert_not invite.reload.active?
  end

  test "signed in parent can accept an invite with a matching existing account" do
    owner = User.create!(name: "Owner Parent", email: "signed-owner@example.com", password: "password123", password_confirmation: "password123")
    invited_parent = User.create!(name: "Partner Parent", email: "partner@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: owner, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))
    invite = BabyInvite.create!(baby: baby, invited_by_user: owner, email: invited_parent.email, expires_at: 3.days.from_now)

    post session_path, params: { email: invited_parent.email, password: "password123" }

    assert_difference -> { baby.users.count }, 1 do
      post invite_acceptance_path(invite.token)
    end

    assert_redirected_to today_path
    assert_equal invited_parent, invite.reload.accepted_by_user
  end

  test "used or expired invites show a calm dead-end state" do
    used_invite = baby_invites(:used)
    expired_invite = baby_invites(:expired)

    get invite_path(used_invite.token)
    assert_response :gone
    assert_match "This invite is no longer available.", response.body

    get invite_path(expired_invite.token)
    assert_response :gone
    assert_match "Ask the other parent for a fresh invite.", response.body
  end

  test "invite acceptance rejects reused invites" do
    invite = baby_invites(:used)

    post invite_acceptance_path(invite.token)

    assert_response :gone
    assert_match "This invite is no longer available.", response.body
  end

  test "invite acceptance rejects mismatched email" do
    owner = User.create!(name: "Owner Parent", email: "mismatch-owner@example.com", password: "password123", password_confirmation: "password123")
    baby = BabyCreator.create!(user: owner, first_name: "Milo", birth_at: Time.zone.local(2026, 3, 20, 3, 45))
    invite = BabyInvite.create!(baby: baby, invited_by_user: owner, email: "partner@example.com", expires_at: 3.days.from_now)

    assert_no_difference -> { User.count } do
      post invite_acceptance_path(invite.token), params: {
        acceptance: {
          name: "Wrong Parent",
          email: "wrong@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Use the invited email address to join this baby log.", response.body
  end
end
