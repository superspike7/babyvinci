class HomeController < ApplicationController
  VISIBLE_EVENT_SKEW = 10.minutes

  def show
    redirect_to new_baby_path unless current_baby

    return unless current_baby

    @next_feed_reminder = current_baby.next_feed_reminder || current_baby.build_next_feed_reminder
    @recent_care_events = visible_care_events.limit(8)
    @last_feed = latest_started_event_for("feed")
    @last_diaper = latest_started_event_for("diaper")
    @active_sleep = current_baby.care_events.active_sleep.first
    @last_sleep = latest_started_event_for("sleep")
    @guidance_notes = Guidance.for_age_in_days(baby_age_in_days(current_baby))
  end

  private
    def visible_care_events
      current_baby.care_events.includes(:user).started_on_or_before(Time.current + VISIBLE_EVENT_SKEW).chronological_desc
    end

    def latest_started_event_for(kind)
      visible_care_events.for_kind(kind).first
    end

    def baby_age_in_days(baby)
      ((Time.zone.today - baby.birth_at.to_date).to_i + 1).clamp(0, Float::INFINITY)
    end
end
