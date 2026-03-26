require "test_helper"

class ConcernFlowsTest < ActionDispatch::IntegrationTest
  test "parent can see concern entry point on today page" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get today_path
    assert_response :success
    assert_select "a[href=?]", concerns_path
  end

  test "parent can view list of concern flows" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get concerns_path
    assert_response :success
    assert_select "h1", text: /Check on something/i
    assert_select "a[href=?]", concern_path("fever")
    assert_select "a[href=?]", concern_path("too_sleepy")
    assert_select "a[href=?]", concern_path("fewer_wet_diapers")
    assert_select "a[href=?]", concern_path("breathing")
    assert_select "a[href=?]", concern_path("vomiting")
  end

  test "parent can complete fever concern flow and see result" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    # Start fever flow
    get concern_path("fever")
    assert_response :success
    assert_select "h1", text: /Fever/i

    # Answer first question
    patch concern_path("fever"), params: {
      answers: { temperature: "warm" }
    }
    assert_redirected_to concern_path("fever")

    # Answer second question
    patch concern_path("fever"), params: {
      answers: { age_hours: "3_months_or_older" }
    }
    assert_redirected_to concern_path("fever")

    # Answer third question
    patch concern_path("fever"), params: {
      answers: { alertness: "alert" }
    }
    assert_redirected_to result_concern_path("fever")

    # View result
    get result_concern_path("fever")
    assert_response :success
    assert_match /Watch closely/i, response.body

    # Verify care event was created
    concern = baby.care_events.for_kind("concern").first
    assert_equal "fever", concern.concern_flow_key
    assert_equal "watch_closely", concern.concern_disposition
    assert_equal "Fever or feels too hot", concern.payload["flow_title"]
  end

  test "parent can complete too_sleepy concern flow with urgent result" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get concern_path("too_sleepy")

    # Answer questions leading to urgent care
    patch concern_path("too_sleepy"), params: { answers: { wake_difficulty: "severe" } }
    patch concern_path("too_sleepy"), params: { answers: { feeding_attempts: "yes_ate_well" } }
    patch concern_path("too_sleepy"), params: { answers: { age_hours: "over_7_days" } }

    follow_redirect!
    assert_match /Seek urgent care now/i, response.body

    concern = baby.care_events.for_kind("concern").first
    assert_equal "seek_urgent_care_now", concern.concern_disposition
  end

  test "parent can complete breathing concern flow with call pediatrician result" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get concern_path("breathing")

    # Answer questions leading to call pediatrician
    patch concern_path("breathing"), params: {
      answers: { breathing_signs: [ "grunting" ] }
    }
    patch concern_path("breathing"), params: {
      answers: { feeding_breathing: "difficult" }
    }

    follow_redirect!
    assert_match /Call your pediatrician today/i, response.body

    concern = baby.care_events.for_kind("concern").first
    assert_equal "call_pediatrician_today", concern.concern_disposition
  end

  test "concern results appear on more page" do
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
        answers: { "temperature" => "warm" },
        version: 1
      }
    )

    sign_in_as(users(:one))

    get more_path
    assert_response :success
    assert_select "a[href=?]", concerns_path, text: /View concerns/i
  end

  test "concern results appear in timeline" do
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
        answers: { "temperature" => "warm" },
        version: 1
      }
    )

    sign_in_as(users(:one))

    get timeline_path
    assert_response :success
    assert_match /Fever/i, response.body
  end

  test "invalid concern flow key redirects to index" do
    baby = BabyCreator.create!(
      user: users(:one),
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    sign_in_as(users(:one))

    get concern_path("invalid_flow")
    assert_redirected_to concerns_path
  end

  private
    def sign_in_as(user)
      post session_path, params: { email: user.email, password: "password" }
      assert_redirected_to today_path
    end
end
