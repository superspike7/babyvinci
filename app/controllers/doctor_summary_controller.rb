class DoctorSummaryController < ApplicationController
  before_action :ensure_baby

  def show
    @window = valid_window
    @window_label = window_label(@window)
    @start_time = Time.current - @window

    @latest_feed = latest_event_for("feed")
    @latest_diaper = latest_event_for("diaper")
    @latest_sleep = latest_event_for("sleep")
    @latest_concern = latest_event_for("concern")
    @latest_concern_flow = ConcernFlow.find(@latest_concern.concern_flow_key) if @latest_concern
    @latest_concern_reason = @latest_concern_flow&.result_reason(@latest_concern.concern_answers)
    @latest_concern_answers = @latest_concern_flow&.answer_summary(@latest_concern.concern_answers) || []

    @care_events = current_baby.care_events
                                .chronological_desc
                                .started_after(@start_time)
                                .limit(100)

    @feed_count = current_baby.care_events.for_kind("feed").started_after(@start_time).count
    @diaper_count = current_baby.care_events.for_kind("diaper").started_after(@start_time).count
    @sleep_count = current_baby.care_events.for_kind("sleep").started_after(@start_time).count
    @concern_count = current_baby.care_events.for_kind("concern").started_after(@start_time).count

    @recent_concerns = current_baby.care_events
                                      .for_kind("concern")
                                      .chronological_desc
                                      .started_after(@start_time)
                                      .limit(5)

    respond_to do |format|
      format.html
      format.text
    end
  end

  private

    VALID_WINDOWS = {
      "24h" => 24.hours,
      "72h" => 72.hours,
      "7d" => 7.days
    }.freeze

    def valid_window
      window_param = params[:window].to_s
      VALID_WINDOWS.fetch(window_param, 72.hours)
    end

    def window_label(window)
      case window
      when 24.hours
        "Last 24 hours"
      when 72.hours
        "Last 72 hours"
      when 7.days
        "Last 7 days"
      else
        "Recent history"
      end
    end

    def latest_event_for(kind)
      current_baby.care_events
                  .for_kind(kind)
                  .started_after(@start_time)
                  .chronological_desc
                  .first
    end
end
