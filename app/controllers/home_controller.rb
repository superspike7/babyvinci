class HomeController < ApplicationController
  def show
    redirect_to new_baby_path unless current_baby

    return unless current_baby

    @recent_care_events = current_baby.care_events.includes(:user).most_recent_first.limit(8)
    @last_feed = current_baby.care_events.for_kind("feed").most_recent_first.first
    @last_diaper = current_baby.care_events.for_kind("diaper").most_recent_first.first
  end
end
