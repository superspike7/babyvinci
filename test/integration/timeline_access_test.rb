require "test_helper"

class TimelineAccessTest < ActionDispatch::IntegrationTest
  test "signed in parent without a baby is sent to baby setup from timeline" do
    user = users(:one)

    post session_path, params: { email: user.email, password: "password" }
    get timeline_path
    follow_redirect!

    assert_response :success
    assert_equal new_baby_path, request.path
  end

  test "parent cannot edit another baby's care event" do
    viewer = users(:one)
    owner = users(:two)
    hidden_baby = BabyCreator.create!(
      user: owner,
      first_name: "Ivy",
      birth_at: Time.zone.local(2026, 3, 21, 5, 0)
    )
    hidden_event = CareEvent.create!(
      baby: hidden_baby,
      user: owner,
      kind: "feed",
      started_at: Time.zone.local(2026, 3, 23, 7, 30),
      payload: { "mode" => "formula" }
    )
    BabyCreator.create!(
      user: viewer,
      first_name: "Milo",
      birth_at: Time.zone.local(2026, 3, 20, 3, 45)
    )

    post session_path, params: { email: viewer.email, password: "password" }

    get edit_care_event_path(hidden_event)

    assert_response :not_found

    patch care_event_path(hidden_event), params: {
      care_event: {
        started_at: "2026-03-23T07:35",
        mode: "breast"
      }
    }

    assert_response :not_found

    delete care_event_path(hidden_event)

    assert_response :not_found
  end
end
