class SleepsController < ApplicationController
  before_action :set_active_sleep, only: [ :end_sleep ]

  def new
    @care_event = current_baby.care_events.new(
      kind: "sleep",
      started_at: Time.current.change(sec: 0),
      payload: {}
    )
  end

  def create
    @care_event = current_baby.care_events.new(care_event_params)
    @care_event.user = current_user
    @care_event.kind = "sleep"

    if @care_event.save
      redirect_to today_path, notice: "Sleep started"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def end_sleep
    if @care_event.update(ended_at: Time.current.change(sec: 0))
      redirect_to today_path, notice: "Sleep ended"
    else
      redirect_to today_path, alert: "Could not end sleep"
    end
  end

  private
    def care_event_params
      params.require(:care_event).permit(:started_at)
    end

    def set_active_sleep
      @care_event = current_baby.care_events.active_sleep.first
      redirect_to today_path, alert: "No active sleep found" unless @care_event
    end
end
