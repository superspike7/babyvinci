class HomeController < ApplicationController
  def show
    redirect_to new_baby_path unless current_baby

    return unless current_baby

    @recent_care_events = current_baby.care_events.includes(:user).chronological_desc.limit(8)
    @last_feed = latest_started_event_for("feed")
    @last_diaper = latest_started_event_for("diaper")
  end

  private
    def latest_started_event_for(kind)
      current_baby.care_events.for_kind(kind).started_on_or_before(Time.current).chronological_desc.first
    end
end
