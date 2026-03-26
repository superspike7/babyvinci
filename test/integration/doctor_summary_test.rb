require "test_helper"

class DoctorSummaryTest < ActionDispatch::IntegrationTest
  test "parent can view doctor summary" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    # Create some events
    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "feed",
      started_at: 2.hours.ago,
      payload: { "mode" => "breast" }
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "diaper",
      started_at: 3.hours.ago,
      payload: { "pee" => true }
    )

    sign_in_as(users(:one))

    get doctor_summary_path
    assert_response :success
    assert_select "h1", text: /Doctor summary/i
    assert_match /Milo/i, response.body
    # Check that the counts are present in separate elements
    assert_select ".text-3xl", text: "1"  # Should find multiple "1" values for feeds, diapers
    assert_match /Feeds/i, response.body
    assert_match /Diapers/i, response.body
  end

  test "doctor summary shows latest context cards" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "feed",
      started_at: 4.hours.ago,
      payload: { "mode" => "breast" }
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "diaper",
      started_at: 3.hours.ago,
      payload: { "pee" => true }
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "sleep",
      started_at: 2.hours.ago,
      payload: {}
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "concern",
      started_at: 1.hour.ago,
      payload: {
        flow_key: "breathing",
        flow_title: "Trouble breathing or breathing seems wrong",
        disposition: "call_pediatrician_today",
        answers: {
          "breathing_signs" => [ "grunting" ],
          "feeding_breathing" => "yes"
        },
        version: 1
      }
    )

    sign_in_as(users(:one))

    get doctor_summary_path
    assert_response :success
    assert_match /Clinic snapshot/i, response.body
    assert_match /Chief concern/i, response.body
    assert_match /Trigger/i, response.body
    assert_match /Parent answers/i, response.body
    assert_match /Call your pediatrician today/i, response.body
    assert_match /Grunting with each breath/i, response.body
    assert_match /Recent status/i, response.body
    assert_match /Latest feed/i, response.body
    assert_match /Latest diaper/i, response.body
    assert_match /Latest sleep/i, response.body
  end

  test "doctor summary shows different time windows" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    # Create an event 2 days ago
    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "feed",
      started_at: 2.days.ago,
      payload: { "mode" => "formula" }
    )

    sign_in_as(users(:one))

    # 24h window - should not show old event
    get doctor_summary_path(window: "24h")
    assert_response :success
    assert_match /Last 24 hours/i, response.body
    assert_select ".text-3xl", text: "0"  # Should find "0" for feeds in this window

    # 72h window (default) - should not show old event
    get doctor_summary_path
    assert_response :success
    assert_match /Last 72 hours/i, response.body
    assert_select ".text-3xl", text: "0"  # Should find "0" for feeds in this window

    # 7d window - should show old event
    get doctor_summary_path(window: "7d")
    assert_response :success
    assert_match /Last 7 days/i, response.body
    assert_select ".text-3xl", text: "1"  # Should find "1" for feeds in this window
  end

  test "doctor summary shows recent concerns" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "concern",
      started_at: 1.hour.ago,
      payload: {
        flow_key: "fever",
        flow_title: "Fever or feels too hot",
        disposition: "watch_closely",
        answers: {
          "temperature" => "warm",
          "age_hours" => "3_months_or_older",
          "alertness" => "alert"
        },
        version: 1
      }
    )

    sign_in_as(users(:one))

    get doctor_summary_path
    assert_response :success
    assert_match /Safety check history/i, response.body
    assert_match /Fever or feels too hot/i, response.body
    assert_match /Watch closely/i, response.body
    assert_match /Parent answers/i, response.body
    assert_match /Warm to touch/i, response.body
  end

  test "doctor summary provides text format for printing" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "feed",
      started_at: 2.hours.ago,
      payload: { "mode" => "breast" }
    )

    CareEvent.create!(
      baby: baby,
      user: users(:one),
      kind: "concern",
      started_at: 1.hour.ago,
      payload: {
        flow_key: "fever",
        flow_title: "Fever or feels too hot",
        disposition: "call_pediatrician_today",
        answers: {
          "temperature" => "measured_high",
          "age_hours" => "3_months_or_older",
          "alertness" => "alert"
        },
        version: 1
      }
    )

    sign_in_as(users(:one))

    get doctor_summary_path(format: :text)
    assert_response :success
    assert_match /DOCTOR SUMMARY/i, response.body
    assert_match /Baby: Milo/i, response.body
    assert_match /Feeds: 1/i, response.body
    assert_match /CLINIC SNAPSHOT/i, response.body
    assert_match /Why this result: Measured 38°C \(100.4°F\) or higher in a baby 3 months or older\./i, response.body
    assert_match /Parent answers:/i, response.body
    assert_match /RECENT CONTEXT/i, response.body
  end

  test "doctor summary includes recent events in timeline" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    5.times do |i|
      CareEvent.create!(
        baby: baby,
        user: users(:one),
        kind: "feed",
        started_at: (i + 1).hours.ago,
        payload: { "mode" => "breast" }
      )
    end

    sign_in_as(users(:one))

    get doctor_summary_path
    assert_response :success
    assert_match /Timeline/i, response.body
    # Should show the 5 feed events
    assert_select ".divide-y", count: 2 # Recent status, Timeline (Safety check history is empty)
  end

  test "doctor summary shows correct baby age" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: 7.days.ago
    )

    sign_in_as(users(:one))

    get doctor_summary_path
    assert_response :success
    # Baby born 7 days ago will be "8 days old" (inclusive counting)
    assert_match /days old/i, response.body
  end

  test "doctor summary is accessible from more page" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get more_path
    assert_response :success
    assert_select "a[href=?]", doctor_summary_path, text: /View summary/i
  end

  private
    def sign_in_as(user)
      post session_path, params: { email: user.email, password: "password" }
      assert_redirected_to today_path
    end
end
