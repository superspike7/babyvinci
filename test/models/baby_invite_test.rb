require "test_helper"

class BabyInviteTest < ActiveSupport::TestCase
  test "active requires unused token before expiry" do
    invite = baby_invites(:pending)

    assert invite.active?

    invite.update!(accepted_at: Time.current)
    assert_not invite.active?

    invite.update!(accepted_at: nil, expires_at: 1.minute.ago)
    assert_not invite.active?
  end

  test "matching_email? normalizes case and whitespace" do
    invite = baby_invites(:pending)

    assert invite.matching_email?("  PARTNER@example.com ")
    assert_not invite.matching_email?("someone-else@example.com")
  end
end
