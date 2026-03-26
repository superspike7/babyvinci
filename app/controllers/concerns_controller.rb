class ConcernsController < ApplicationController
  before_action :ensure_baby
  before_action :set_concern_flow, only: %i[show update]

  def index
    @concern_flows = ConcernFlow.all
  end

  def show
    # Reset session if switching to a different concern flow
    if session[:concern_flow_key] != @concern_flow.key
      session[:concern_answers] = {}
      session[:concern_current_question] = 0
      session[:concern_flow_key] = @concern_flow.key
    end

    @answers = session_answers
    @current_question_index = current_question_index
    @current_question = @concern_flow.questions[@current_question_index]
    @result_disposition = session[:concern_result_disposition]
  end

  def update
    @answers = session_answers.merge(answer_params.to_h)
    session[:concern_answers] = @answers

    current_idx = current_question_index
    next_idx = current_idx + 1

    if next_idx >= @concern_flow.questions.length
      # Flow complete - evaluate and save result
      disposition = @concern_flow.evaluate(@answers)
      save_concern_result(disposition)
      session.delete(:concern_answers)
      redirect_to result_concern_path(@concern_flow)
    else
      # Move to next question
      session[:concern_current_question] = next_idx
      redirect_to concern_path(@concern_flow)
    end
  end

  def result
    @concern_flow = ConcernFlow.find(params.require(:id))
    @care_event = current_baby.care_events.for_kind("concern").order(created_at: :desc).first

    if @care_event.nil? || @care_event.concern_flow_key != @concern_flow.key
      redirect_to concerns_path
      return
    end

    @disposition = @care_event.concern_disposition
    @disposition_label = ConcernFlow.disposition_label(@disposition)
    @disposition_description = ConcernFlow.disposition_description(@disposition)
  end

  private

    def set_concern_flow
      @concern_flow = ConcernFlow.find(params[:id])
      redirect_to concerns_path unless @concern_flow
    end

    def session_answers
      session[:concern_answers] ||= {}
    end

    def current_question_index
      session[:concern_current_question] ||= 0
    end

    def answer_params
      params.fetch(:answers, {}).permit(@concern_flow.questions.map { |q| q[:id] })
    end

    def save_concern_result(disposition)
      current_baby.care_events.create!(
        user: Current.user,
        kind: "concern",
        started_at: Time.current,
        payload: {
          flow_key: @concern_flow.key,
          flow_title: @concern_flow.title,
          answers: @answers,
          disposition: disposition,
          version: 1
        }
      )
    end
end
