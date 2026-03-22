class DiapersController < ApplicationController
  before_action :require_current_baby

  def new
    @care_event = current_baby.care_events.new(kind: "diaper", started_at: Time.zone.now.change(sec: 0))
  end

  def create
    @care_event = current_baby.care_events.new(
      user: current_user,
      kind: "diaper",
      started_at: diaper_started_at,
      payload: diaper_payload
    )

    if @care_event.save
      redirect_to today_path, notice: "Diaper logged."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def care_event_params
      params.require(:care_event).permit(:started_at, :diaper_type, :color)
    end

    def diaper_started_at
      value = care_event_params[:started_at]
      return Time.zone.now.change(sec: 0) if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end

    def diaper_payload
      diaper_type = care_event_params[:diaper_type]
      includes_poop = %w[poop both].include?(diaper_type)

      {
        "pee" => %w[wet both].include?(diaper_type),
        "poop" => includes_poop,
        "color" => includes_poop ? care_event_params[:color].presence : nil
      }.compact
    end

    def require_current_baby
      redirect_to new_baby_path unless current_baby
    end
end
