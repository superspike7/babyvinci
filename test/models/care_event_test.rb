require "test_helper"

class CareEventTest < ActiveSupport::TestCase
  test "most recent first orders by started_at then created_at" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    older = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "feed",
      started_at: Time.zone.local(2026, 3, 23, 7, 0),
      payload: { "mode" => "formula" }
    )
    newer = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "diaper",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: { "pee" => true }
    )

    assert_equal [ newer, older ], baby.care_events.most_recent_first.to_a
  end
end
