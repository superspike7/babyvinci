class CareEventsController < ApplicationController
  before_action :require_current_baby
  before_action :set_care_event
  before_action :set_return_path
  before_action :reject_sleep_edits, only: [ :edit, :update ]

  def edit
    render edit_template
  end

  def update
    @care_event.assign_attributes(
      started_at: started_at_from_params,
      payload: payload_for(@care_event)
    )

    if @care_event.save
      redirect_to @return_path, notice: "#{@care_event.kind.capitalize} updated."
    else
      render edit_template, status: :unprocessable_entity
    end
  end

  def destroy
    kind_name = @care_event.kind.capitalize
    @care_event.destroy!

    redirect_to @return_path, notice: "#{kind_name} deleted."
  end

  private
    def set_care_event
      @care_event = current_baby.care_events.find(params[:id])
    end

    def set_return_path
      @return_path = case params[:return_to].presence
      when today_path
        today_path
      when timeline_path
        timeline_path
      else
        timeline_path
      end

      @return_label = @return_path == today_path ? "Back to today" : "Back to timeline"
    end

    def edit_template
      @care_event.feed? ? "feeds/edit" : "diapers/edit"
    end

    def started_at_from_params
      value = care_event_params[:started_at]
      return Time.zone.now.change(sec: 0) if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end

    def payload_for(care_event)
      care_event.feed? ? feed_payload : diaper_payload
    end

    def care_event_params
      params.fetch(:care_event, ActionController::Parameters.new).permit(:started_at, :mode, :amount_ml, :side, :duration_min, :diaper_type, :color)
    end

    def feed_payload
      {
        "mode" => care_event_params[:mode],
        "amount_ml" => integer_or_nil(care_event_params[:amount_ml]),
        "side" => care_event_params[:side].presence,
        "duration_min" => integer_or_nil(care_event_params[:duration_min])
      }.compact
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

    def integer_or_nil(value)
      return nil if value.blank?

      Integer(value, 10)
    rescue ArgumentError, TypeError
      value
    end

    def require_current_baby
      redirect_to new_baby_path unless current_baby
    end

    def reject_sleep_edits
      if @care_event.sleep?
        redirect_to @return_path, alert: "Sleep events cannot be edited."
      end
    end
end
