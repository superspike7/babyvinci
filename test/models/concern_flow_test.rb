# frozen_string_literal: true

require "test_helper"

class ConcernFlowTest < ActiveSupport::TestCase
  test "all flows can be listed" do
    flows = ConcernFlow.all
    assert_equal 5, flows.length

    flow_keys = flows.map(&:key)
    assert_includes flow_keys, "fever"
    assert_includes flow_keys, "too_sleepy"
    assert_includes flow_keys, "fewer_wet_diapers"
    assert_includes flow_keys, "breathing"
    assert_includes flow_keys, "vomiting"
  end

  test "fever flow returns urgent care for high fever under 3 months" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "measured_high",
      "age_hours" => "under_3_months",
      "alertness" => "alert"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "fever flow returns urgent care for very hot regardless of age" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "very_hot",
      "age_hours" => "3_months_or_older",
      "alertness" => "alert"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "fever flow returns urgent care for not alert regardless of temperature" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "warm",
      "age_hours" => "3_months_or_older",
      "alertness" => "not_alert"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "fever flow returns call pediatrician for measured high in older baby" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "measured_high",
      "age_hours" => "3_months_or_older",
      "alertness" => "alert"
    }

    assert_equal "call_pediatrician_today", flow.evaluate(answers)
  end

  test "fever flow returns call pediatrician for warm in young baby" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "warm",
      "age_hours" => "under_3_months",
      "alertness" => "alert"
    }

    assert_equal "call_pediatrician_today", flow.evaluate(answers)
  end

  test "fever flow returns watch closely for warm older baby" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "warm",
      "age_hours" => "3_months_or_older",
      "alertness" => "alert"
    }

    assert_equal "watch_closely", flow.evaluate(answers)
  end

  test "too sleepy flow returns urgent care for severe difficulty" do
    flow = ConcernFlow.find("too_sleepy")
    answers = {
      "wake_difficulty" => "severe",
      "feeding_attempts" => "yes_ate_well",
      "age_hours" => "over_7_days"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "too sleepy flow returns urgent care for moderate difficulty in newborn with poor feeding" do
    flow = ConcernFlow.find("too_sleepy")
    answers = {
      "wake_difficulty" => "moderate",
      "feeding_attempts" => "yes_refused",
      "age_hours" => "under_24_hours"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "too sleepy flow returns watch closely for mild drowsiness" do
    flow = ConcernFlow.find("too_sleepy")
    answers = {
      "wake_difficulty" => "mild",
      "feeding_attempts" => "yes_ate_well",
      "age_hours" => "over_7_days"
    }

    assert_equal "watch_closely", flow.evaluate(answers)
  end

  test "fewer wet diapers flow returns urgent care for no diapers day 6+" do
    flow = ConcernFlow.find("fewer_wet_diapers")
    answers = {
      "wet_diapers_24h" => "none",
      "age_days" => "day_6_plus",
      "other_signs" => [ "none" ]
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "fewer wet diapers flow returns urgent care for sunken soft spot" do
    flow = ConcernFlow.find("fewer_wet_diapers")
    answers = {
      "wet_diapers_24h" => "3_to_5",
      "age_days" => "day_6_plus",
      "other_signs" => [ "sunken_soft_spot" ]
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "fewer wet diapers flow returns watch closely for normal diapers" do
    flow = ConcernFlow.find("fewer_wet_diapers")
    answers = {
      "wet_diapers_24h" => "6_plus",
      "age_days" => "day_6_plus",
      "other_signs" => [ "none" ]
    }

    assert_equal "watch_closely", flow.evaluate(answers)
  end

  test "breathing flow returns urgent care for blue color" do
    flow = ConcernFlow.find("breathing")
    answers = {
      "breathing_signs" => [ "blue", "fast" ],
      "feeding_breathing" => "yes"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "breathing flow returns urgent care for cannot feed" do
    flow = ConcernFlow.find("breathing")
    answers = {
      "breathing_signs" => [ "fast" ],
      "feeding_breathing" => "cannot"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "breathing flow returns call pediatrician for difficult feeding" do
    flow = ConcernFlow.find("breathing")
    answers = {
      "breathing_signs" => [ "grunting" ],
      "feeding_breathing" => "difficult"
    }

    assert_equal "call_pediatrician_today", flow.evaluate(answers)
  end

  test "breathing flow returns call pediatrician for grunting alone" do
    flow = ConcernFlow.find("breathing")
    answers = {
      "breathing_signs" => [ "grunting" ],
      "feeding_breathing" => "yes"
    }

    assert_equal "call_pediatrician_today", flow.evaluate(answers)
  end

  test "breathing flow returns watch closely for just fast breathing with normal feeding" do
    flow = ConcernFlow.find("breathing")
    answers = {
      "breathing_signs" => [ "fast" ],
      "feeding_breathing" => "yes"
    }

    assert_equal "watch_closely", flow.evaluate(answers)
  end

  test "vomiting flow returns urgent care for green vomit" do
    flow = ConcernFlow.find("vomiting")
    answers = {
      "vomit_frequency" => "once",
      "vomit_appearance" => "green",
      "wet_diapers" => "yes_normal"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "vomiting flow returns urgent care for blood in vomit" do
    flow = ConcernFlow.find("vomiting")
    answers = {
      "vomit_frequency" => "few_times",
      "vomit_appearance" => "blood",
      "wet_diapers" => "yes_normal"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "vomiting flow returns urgent care for no wet diapers" do
    flow = ConcernFlow.find("vomiting")
    answers = {
      "vomit_frequency" => "few_times",
      "vomit_appearance" => "milk",
      "wet_diapers" => "none"
    }

    assert_equal "seek_urgent_care_now", flow.evaluate(answers)
  end

  test "vomiting flow returns call pediatrician for projectile vomiting" do
    flow = ConcernFlow.find("vomiting")
    answers = {
      "vomit_frequency" => "few_times",
      "vomit_appearance" => "projectile",
      "wet_diapers" => "yes_normal"
    }

    assert_equal "call_pediatrician_today", flow.evaluate(answers)
  end

  test "vomiting flow returns watch closely for occasional milk vomit with normal diapers" do
    flow = ConcernFlow.find("vomiting")
    answers = {
      "vomit_frequency" => "once",
      "vomit_appearance" => "milk",
      "wet_diapers" => "yes_normal"
    }

    assert_equal "watch_closely", flow.evaluate(answers)
  end

  test "disposition labels are readable" do
    assert_equal "Watch closely", ConcernFlow.disposition_label("watch_closely")
    assert_equal "Call your pediatrician today", ConcernFlow.disposition_label("call_pediatrician_today")
    assert_equal "Seek urgent care now", ConcernFlow.disposition_label("seek_urgent_care_now")
  end

  test "disposition descriptions are present" do
    assert ConcernFlow.disposition_description("watch_closely").present?
    assert ConcernFlow.disposition_description("call_pediatrician_today").present?
    assert ConcernFlow.disposition_description("seek_urgent_care_now").present?
  end

  test "answer summaries translate selected answers into readable labels" do
    flow = ConcernFlow.find("fever")
    answers = {
      "temperature" => "measured_high",
      "age_hours" => "3_months_or_older",
      "alertness" => "alert"
    }

    assert_equal [
      {
        question: "How warm does your baby feel to touch?",
        answer: "Measured 38°C (100.4°F) or higher"
      },
      {
        question: "How old is your baby?",
        answer: "3 months or older"
      },
      {
        question: "Is your baby alert and responsive?",
        answer: "Yes, alert and responsive"
      }
    ], flow.answer_summary(answers)
  end

  test "result reasons explain the selected trigger" do
    flow = ConcernFlow.find("breathing")
    answers = {
      "breathing_signs" => [ "grunting" ],
      "feeding_breathing" => "yes"
    }

    assert_equal "Grunting with each breath.", flow.result_reason(answers)
  end
end
