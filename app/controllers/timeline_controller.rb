class TimelineController < ApplicationController
  def show
    redirect_to new_baby_path and return unless current_baby

    @care_events = current_baby.care_events.includes(:user).most_recent_first
    @timeline_days = @care_events.group_by { |event| event.started_at.to_date }
  end
end
