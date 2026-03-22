require "test_helper"

class BabyTest < ActiveSupport::TestCase
  test "requires first name and birth time" do
    baby = Baby.new

    assert_not baby.valid?
    assert_includes baby.errors[:first_name], "can't be blank"
    assert_includes baby.errors[:birth_at], "can't be blank"
  end

  test "creates a parent membership for the creator" do
    user = users(:one)

    baby = nil

    assert_difference [ "Baby.count", "BabyMembership.count" ], 1 do
      baby = BabyCreator.create!(user:, first_name: "Milo", birth_at: Time.zone.parse("2026-03-20 03:45"))
    end

    assert_equal user, baby.created_by_user
    assert_equal [ user ], baby.users
    assert_equal "parent", baby.baby_memberships.first.role
  end
end
