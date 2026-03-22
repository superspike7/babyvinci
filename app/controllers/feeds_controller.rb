class FeedsController < ApplicationController
  before_action :require_current_baby

  def new
    @care_event = current_baby.care_events.new(kind: "feed", started_at: Time.zone.now.change(sec: 0))
  end

  def create
    @care_event = current_baby.care_events.new(
      user: current_user,
      kind: "feed",
      started_at: feed_started_at,
      payload: feed_payload
    )

    if @care_event.save
      redirect_to today_path, notice: "Feed logged."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def care_event_params
      params.require(:care_event).permit(:started_at, :mode, :amount_ml, :side, :duration_min)
    end

    def feed_started_at
      value = care_event_params[:started_at]
      return Time.zone.now.change(sec: 0) if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end

    def feed_payload
      {
        "mode" => care_event_params[:mode],
        "amount_ml" => integer_or_nil(care_event_params[:amount_ml]),
        "side" => care_event_params[:side].presence,
        "duration_min" => integer_or_nil(care_event_params[:duration_min])
      }.compact
    end

    def integer_or_nil(value)
      return nil if value.blank?

      Integer(value, 10)
    rescue ArgumentError, TypeError
      value
    end

    def require_current_baby
      redirect_to new_baby_path unless current_baby
    end
end
