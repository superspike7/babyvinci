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

  test "diaper requires a diaper type in payload" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    event = CareEvent.new(
      baby: baby,
      user: users(:one),
      kind: "diaper",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: {}
    )

    assert_not event.valid?
    assert_includes event.errors[:diaper_type], "can't be blank"
  end

  test "sleep can be created without special payload" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: {}
    )

    assert sleep.sleep?
    assert sleep.active_sleep?
    assert_nil sleep.ended_at
  end

  test "sleep can be ended" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: {}
    )

    sleep.update!(ended_at: Time.zone.local(2026, 3, 23, 9, 30))

    assert sleep.completed_sleep?
    assert_not sleep.active_sleep?
    assert_equal 120, sleep.duration_minutes
  end

  test "active sleep duration does not go negative when start time is in the future" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 1.hour.from_now,
      payload: {}
    )

    assert_equal 0, sleep.duration_minutes
  end

  test "sleep end must be after start time" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      ended_at: Time.zone.local(2026, 3, 23, 8, 30),
      payload: {}
    )

    assert_not sleep.update(started_at: Time.zone.local(2026, 3, 23, 9, 30), ended_at: Time.zone.local(2026, 3, 23, 8, 30))
    assert_includes sleep.errors[:ended_at], "must be after the start time"
  end

  test "completed sleep cannot be reopened" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      ended_at: Time.zone.local(2026, 3, 23, 8, 30),
      payload: {}
    )

    assert_not sleep.update(ended_at: nil)
    assert_includes sleep.errors[:ended_at], "can't be blank"
  end

  test "cannot create overlapping active sleep" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: {}
    )

    second_sleep = CareEvent.new(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 8, 30),
      payload: {}
    )

    assert_not second_sleep.valid?
    assert_includes second_sleep.errors[:base], "Cannot start a new sleep while another is active"
  end

  test "can create new sleep after ending previous one" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    first_sleep = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: {}
    )

    first_sleep.update!(ended_at: Time.zone.local(2026, 3, 23, 9, 30))

    second_sleep = CareEvent.new(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 10, 30),
      payload: {}
    )

    assert second_sleep.valid?
    assert second_sleep.save
  end

  test "active_sleep scope returns only active sleep events" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    # Create completed sleep first (no active sleep yet)
    completed = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 5, 30),
      ended_at: Time.zone.local(2026, 3, 23, 6, 30),
      payload: {}
    )

    # Then create active sleep
    active = CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: {}
    )

    assert_equal [ active ], baby.care_events.active_sleep.to_a
    assert_not_includes baby.care_events.active_sleep, completed
  end
end
