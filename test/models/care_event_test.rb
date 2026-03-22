require "test_helper"

class CareEventTest < ActiveSupport::TestCase
  test "chronological desc orders by started_at then id" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    older = CareEvent.create!(baby: baby, user: users(:one), kind: "feed", started_at: Time.zone.local(2026, 3, 23, 7, 0), payload: { "mode" => "formula" })
    newer = CareEvent.create!(baby: baby, user: users(:one), kind: "diaper", started_at: Time.zone.local(2026, 3, 23, 7, 30), payload: { "pee" => true })

    assert_equal [ newer, older ], baby.care_events.chronological_desc.to_a
  end

  test "chronological desc keeps later started_at ahead of later-created backfill" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    in_order = CareEvent.create!(baby: baby, user: users(:one), kind: "feed", started_at: Time.zone.local(2026, 3, 22, 23, 0), payload: { "mode" => "formula" })
    backfill = CareEvent.create!(baby: baby, user: users(:one), kind: "feed", started_at: Time.zone.local(2026, 3, 22, 13, 30), payload: { "mode" => "formula", "amount_ml" => 30 })

    in_order.update_columns(created_at: Time.zone.local(2026, 3, 23, 3, 5), updated_at: Time.zone.local(2026, 3, 23, 3, 5))
    backfill.update_columns(created_at: Time.zone.local(2026, 3, 23, 3, 10), updated_at: Time.zone.local(2026, 3, 23, 3, 10))

    assert_equal [ in_order, backfill ], baby.care_events.for_kind("feed").chronological_desc.to_a
  end
end
