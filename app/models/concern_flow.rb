# frozen_string_literal: true

class ConcernFlow
  DISPOSITIONS = {
    "watch_closely" => {
      label: "Watch closely",
      description: "Keep watching and log if anything changes."
    },
    "call_pediatrician_today" => {
      label: "Call your pediatrician today",
      description: "Contact your pediatrician's office for guidance."
    },
    "seek_urgent_care_now" => {
      label: "Seek urgent care now",
      description: "Go to urgent care or the emergency department."
    }
  }.freeze

  FLOWS = {
    "fever" => {
      key: "fever",
      title: "Fever or feels too hot",
      opening: "Is your baby unusually warm or showing signs of fever?",
      questions: [
        {
          id: "temperature",
          text: "How warm does your baby feel to touch?",
          type: "choice",
          options: [
            { value: "warm", label: "Warm to touch" },
            { value: "very_hot", label: "Very hot or burning" },
            { value: "measured_high", label: "Measured 38°C (100.4°F) or higher" }
          ]
        },
        {
          id: "age_hours",
          text: "How old is your baby?",
          type: "choice",
          options: [
            { value: "under_3_months", label: "Under 3 months (90 days)" },
            { value: "3_months_or_older", label: "3 months or older" }
          ]
        },
        {
          id: "alertness",
          text: "Is your baby alert and responsive?",
          type: "choice",
          options: [
            { value: "alert", label: "Yes, alert and responsive" },
            { value: "not_alert", label: "No, unusually sleepy or hard to wake" }
          ]
        }
      ],
      logic: ->(answers) {
        temp = answers["temperature"]
        age = answers["age_hours"]
        alert = answers["alertness"]

        return "seek_urgent_care_now" if temp == "measured_high" && age == "under_3_months"
        return "seek_urgent_care_now" if temp == "very_hot"
        return "seek_urgent_care_now" if alert == "not_alert"
        return "call_pediatrician_today" if temp == "measured_high" && age == "3_months_or_older"
        return "call_pediatrician_today" if temp == "warm" && age == "under_3_months"
        "watch_closely"
      }
    },
    "too_sleepy" => {
      key: "too_sleepy",
      title: "Too sleepy to feed or hard to wake",
      opening: "Is your baby having trouble staying awake for feeds?",
      questions: [
        {
          id: "wake_difficulty",
          text: "How hard is it to wake your baby for feeding?",
          type: "choice",
          options: [
            { value: "mild", label: "A little drowsy but wakes easily" },
            { value: "moderate", label: "Needs extra effort to wake" },
            { value: "severe", label: "Very difficult or impossible to wake" }
          ]
        },
        {
          id: "feeding_attempts",
          text: "Have you tried feeding in the last 3 hours?",
          type: "choice",
          options: [
            { value: "yes_ate_well", label: "Yes, and baby ate well" },
            { value: "yes_refused", label: "Yes, but baby refused or ate poorly" },
            { value: "no", label: "No, baby has been sleeping" }
          ]
        },
        {
          id: "age_hours",
          text: "How old is your baby?",
          type: "choice",
          options: [
            { value: "under_24_hours", label: "Under 24 hours old" },
            { value: "1_to_7_days", label: "1-7 days old" },
            { value: "over_7_days", label: "Over 7 days old" }
          ]
        }
      ],
      logic: ->(answers) {
        wake = answers["wake_difficulty"]
        feed = answers["feeding_attempts"]
        age = answers["age_hours"]

        return "seek_urgent_care_now" if wake == "severe"
        return "seek_urgent_care_now" if wake == "moderate" && feed == "yes_refused" && age == "under_24_hours"
        return "call_pediatrician_today" if wake == "moderate" && feed == "yes_refused"
        return "call_pediatrician_today" if wake == "moderate" && age == "under_24_hours"
        "watch_closely"
      }
    },
    "fewer_wet_diapers" => {
      key: "fewer_wet_diapers",
      title: "Fewer wet diapers or dehydration concern",
      opening: "Are you noticing fewer wet diapers than expected?",
      questions: [
        {
          id: "wet_diapers_24h",
          text: "How many wet diapers in the last 24 hours?",
          type: "choice",
          options: [
            { value: "none", label: "None" },
            { value: "1_to_2", label: "1-2" },
            { value: "3_to_5", label: "3-5" },
            { value: "6_plus", label: "6 or more" }
          ]
        },
        {
          id: "age_days",
          text: "How old is your baby?",
          type: "choice",
          options: [
            { value: "day_1", label: "Day 1 (first 24 hours)" },
            { value: "day_2", label: "Day 2" },
            { value: "day_3_to_5", label: "Days 3-5" },
            { value: "day_6_plus", label: "Day 6 or older" }
          ]
        },
        {
          id: "other_signs",
          text: "Are there other signs of dehydration?",
          type: "multiselect",
          options: [
            { value: "dry_mouth", label: "Dry mouth or tongue" },
            { value: "sunken_soft_spot", label: "Sunken soft spot on head" },
            { value: "no_tears", label: "No tears when crying" },
            { value: "none", label: "None of these" }
          ]
        }
      ],
      logic: ->(answers) {
        diapers = answers["wet_diapers_24h"]
        age = answers["age_days"]
        signs = Array(answers["other_signs"])

        has_sunken_spot = signs.include?("sunken_soft_spot")
        has_dry_mouth = signs.include?("dry_mouth")
        has_no_tears = signs.include?("no_tears")

        return "seek_urgent_care_now" if diapers == "none" && age == "day_6_plus"
        return "seek_urgent_care_now" if has_sunken_spot
        return "call_pediatrician_today" if diapers == "none" && age == "day_3_to_5"
        return "call_pediatrician_today" if diapers == "1_to_2" && age == "day_6_plus"
        return "call_pediatrician_today" if has_dry_mouth && has_no_tears
        "watch_closely"
      }
    },
    "breathing" => {
      key: "breathing",
      title: "Trouble breathing or breathing seems wrong",
      opening: "Is your baby having difficulty breathing?",
      questions: [
        {
          id: "breathing_signs",
          text: "What breathing signs are you seeing?",
          type: "multiselect",
          options: [
            { value: "fast", label: "Breathing very fast" },
            { value: "grunting", label: "Grunting with each breath" },
            { value: "flaring", label: "Nostrils flaring" },
            { value: "retracting", label: "Skin pulling in between ribs" },
            { value: "blue", label: "Blue or gray color around lips/face" },
            { value: "pauses", label: "Long pauses between breaths" },
            { value: "none", label: "None of these, just seems different" }
          ]
        },
        {
          id: "feeding_breathing",
          text: "Can your baby feed while breathing?",
          type: "choice",
          options: [
            { value: "yes", label: "Yes, feeding normally" },
            { value: "difficult", label: "Feeding is difficult" },
            { value: "cannot", label: "Cannot feed due to breathing" }
          ]
        }
      ],
      logic: ->(answers) {
        signs = Array(answers["breathing_signs"])
        feeding = answers["feeding_breathing"]

        urgent_signs = %w[grunting flaring retracting blue pauses]
        has_urgent = signs.any? { |s| urgent_signs.include?(s) }

        return "seek_urgent_care_now" if signs.include?("blue")
        return "seek_urgent_care_now" if feeding == "cannot"
        return "seek_urgent_care_now" if signs.include?("pauses")
        return "call_pediatrician_today" if has_urgent
        return "call_pediatrician_today" if feeding == "difficult"
        "watch_closely"
      }
    },
    "vomiting" => {
      key: "vomiting",
      title: "Repeated vomiting or not keeping feeds down",
      opening: "Is your baby vomiting or unable to keep feeds down?",
      questions: [
        {
          id: "vomit_frequency",
          text: "How often is the vomiting happening?",
          type: "choice",
          options: [
            { value: "once", label: "Once in the last few hours" },
            { value: "few_times", label: "A few times today" },
            { value: "after_every_feed", label: "After almost every feed" }
          ]
        },
        {
          id: "vomit_appearance",
          text: "What does the vomit look like?",
          type: "choice",
          options: [
            { value: "milk", label: "Milk or formula only" },
            { value: "green", label: "Green or yellow" },
            { value: "blood", label: "Contains blood" },
            { value: "projectile", label: "Forceful/projectile" }
          ]
        },
        {
          id: "wet_diapers",
          text: "Is your baby still having wet diapers?",
          type: "choice",
          options: [
            { value: "yes_normal", label: "Yes, normal amount" },
            { value: "yes_fewer", label: "Yes, but fewer than usual" },
            { value: "none", label: "None in last 6+ hours" }
          ]
        }
      ],
      logic: ->(answers) {
        freq = answers["vomit_frequency"]
        appearance = answers["vomit_appearance"]
        diapers = answers["wet_diapers"]

        return "seek_urgent_care_now" if appearance == "green"
        return "seek_urgent_care_now" if appearance == "blood"
        return "seek_urgent_care_now" if diapers == "none"
        return "seek_urgent_care_now" if freq == "after_every_feed" && diapers == "yes_fewer"
        return "call_pediatrician_today" if appearance == "projectile"
        return "call_pediatrician_today" if freq == "after_every_feed"
        "watch_closely"
      }
    }
  }.freeze

  def self.all
    FLOWS.values.map { |flow| new(flow) }
  end

  def self.find(key)
    flow_data = FLOWS[key]
    return nil unless flow_data

    new(flow_data)
  end

  def self.disposition_label(key)
    DISPOSITIONS[key]&.fetch(:label, key.to_s.humanize)
  end

  def self.disposition_description(key)
    DISPOSITIONS[key]&.fetch(:description, "")
  end

  attr_reader :key, :title, :opening, :questions, :logic

  def initialize(flow_data)
    @key = flow_data[:key]
    @title = flow_data[:title]
    @opening = flow_data[:opening]
    @questions = flow_data[:questions]
    @logic = flow_data[:logic]
  end

  def question(id)
    questions.find { |q| q[:id] == id }
  end

  def evaluate(answers)
    logic.call(answers)
  end

  def answer_summary(answers)
    answers ||= {}

    questions.filter_map do |question|
      raw_answer = answers[question[:id]]
      next if raw_answer.blank?

      {
        question: question[:text],
        answer: formatted_answer(question, raw_answer)
      }
    end
  end

  def result_reason(answers)
    answers ||= {}

    case key
    when "fever"
      fever_reason(answers)
    when "too_sleepy"
      too_sleepy_reason(answers)
    when "fewer_wet_diapers"
      fewer_wet_diapers_reason(answers)
    when "breathing"
      breathing_reason(answers)
    when "vomiting"
      vomiting_reason(answers)
    end
  end

  def to_param
    key
  end

  private

    def formatted_answer(question, raw_answer)
      case question[:type]
      when "choice"
        option_label(question, raw_answer)
      when "multiselect"
        Array(raw_answer).map { |value| option_label(question, value) }.join(", ")
      else
        raw_answer.to_s
      end
    end

    def option_label(question, value)
      option = question[:options].find { |candidate| candidate[:value] == value }
      option ? option.fetch(:label, value.to_s.humanize) : value.to_s.humanize
    end

    def fever_reason(answers)
      temp = answers["temperature"]
      age = answers["age_hours"]
      alert = answers["alertness"]

      return "Measured 38°C (100.4°F) or higher in a baby under 3 months." if temp == "measured_high" && age == "under_3_months"
      return "Baby felt very hot or burning." if temp == "very_hot"
      return "Baby was unusually sleepy or hard to wake." if alert == "not_alert"
      return "Measured 38°C (100.4°F) or higher in a baby 3 months or older." if temp == "measured_high" && age == "3_months_or_older"
      return "Baby felt warm to touch and is under 3 months." if temp == "warm" && age == "under_3_months"
      return "Baby felt warm to touch and is 3 months or older." if temp == "warm" && age == "3_months_or_older"

      "No urgent fever threshold was met."
    end

    def too_sleepy_reason(answers)
      wake = answers["wake_difficulty"]
      feed = answers["feeding_attempts"]
      age = answers["age_hours"]

      return "Very difficult or impossible to wake for feeding." if wake == "severe"
      return "Needs extra effort to wake, refused feeds, and is under 24 hours old." if wake == "moderate" && feed == "yes_refused" && age == "under_24_hours"
      return "Needs extra effort to wake and refused feeds." if wake == "moderate" && feed == "yes_refused"
      return "Needs extra effort to wake and is under 24 hours old." if wake == "moderate" && age == "under_24_hours"
      return "A little drowsy but wakes easily." if wake == "mild"
      return "Needs extra effort to wake, but did not refuse feeds and is older than 24 hours." if wake == "moderate"

      "No urgent sleepiness threshold was met."
    end

    def fewer_wet_diapers_reason(answers)
      diapers = answers["wet_diapers_24h"]
      age = answers["age_days"]
      signs = Array(answers["other_signs"])

      return "No wet diapers in a baby day 6 or older." if diapers == "none" && age == "day_6_plus"
      return "Sunken soft spot on the head." if signs.include?("sunken_soft_spot")
      return "No wet diapers on days 3-5." if diapers == "none" && age == "day_3_to_5"
      return "Only 1-2 wet diapers in a baby day 6 or older." if diapers == "1_to_2" && age == "day_6_plus"
      return "Dry mouth or tongue and no tears when crying." if signs.include?("dry_mouth") && signs.include?("no_tears")
      return "Wet diapers are within the expected range and no dehydration signs were selected." if diapers == "6_plus" && signs == [ "none" ]

      "No urgent dehydration threshold was met."
    end

    def breathing_reason(answers)
      signs = Array(answers["breathing_signs"])
      feeding = answers["feeding_breathing"]

      return "Blue or gray color around the lips or face." if signs.include?("blue")
      return "Cannot feed because of breathing." if feeding == "cannot"
      return "Long pauses between breaths." if signs.include?("pauses")
      return "Grunting with each breath." if signs.include?("grunting")
      return "Feeding is difficult because of breathing." if feeding == "difficult"
      return "Breathing is very fast without other urgent signs." if signs.include?("fast")

      "No urgent breathing threshold was met."
    end

    def vomiting_reason(answers)
      freq = answers["vomit_frequency"]
      appearance = answers["vomit_appearance"]
      diapers = answers["wet_diapers"]

      return "Green or yellow vomit." if appearance == "green"
      return "Blood in vomit." if appearance == "blood"
      return "No wet diapers in the last 6+ hours." if diapers == "none"
      return "Vomiting after almost every feed with fewer wet diapers." if freq == "after_every_feed" && diapers == "yes_fewer"
      return "Forceful or projectile vomiting." if appearance == "projectile"
      return "Vomiting after almost every feed." if freq == "after_every_feed"
      return "A single milk or formula vomit with normal diapers." if freq == "once" && appearance == "milk" && diapers == "yes_normal"

      "No urgent vomiting threshold was met."
    end
end
