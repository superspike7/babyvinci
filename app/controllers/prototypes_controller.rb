class PrototypesController < ApplicationController
  before_action :setup_mock_data
  helper_method :event_icon, :event_summary, :time_ago

  def index
    redirect_to prototypes_command_deck_path
  end

  def command_deck
    render layout: "prototypes"
  end

  def context_aware
    render layout: "prototypes"
  end

  def action_rows
    render layout: "prototypes"
  end

  private

  def setup_mock_data
    @last_breast = "left"
    @current_time = Time.current

    @activities = [
      { type: "feeding", time: 30.minutes.ago, duration: 25, side: "left", method: "breast", note: "Baby fell asleep", mood: "content" },
      { type: "diaper", time: 1.hour.ago, wet: true, dirty: false, color: "yellow", consistency: "normal" },
      { type: "sleep", time: 1.5.hours.ago, duration: 85, location: "crib", quality: "deep" },
      { type: "feeding", time: 3.hours.ago, duration: 20, side: "right", method: "bottle", amount: 90, note: "", mood: "fussy" },
      { type: "pumping", time: 3.5.hours.ago, duration: 15, left_yield: 60, right_yield: 45, total: 105 },
      { type: "diaper", time: 4.hours.ago, wet: true, dirty: true, color: "brown", consistency: "normal" },
      { type: "feeding", time: 5.hours.ago, duration: 30, side: "left", method: "breast", note: "Cluster feeding", mood: "hungry" },
      { type: "sleep", time: 6.hours.ago, duration: 42, location: "carrier", quality: "light" },
      { type: "diaper", time: 6.5.hours.ago, wet: true, dirty: false, color: "yellow", consistency: "normal" },
      { type: "feeding", time: 7.hours.ago, duration: 18, side: "right", method: "breast", note: "", mood: "sleepy" }
    ]
  end

  def event_icon(type)
    icons = {
      "feeding" => "🍼",
      "diaper" => "💩",
      "sleep" => "😴",
      "pumping" => "🤱"
    }
    icons[type] || "📋"
  end

  def event_summary(activity)
    case activity[:type]
    when "feeding"
      side = activity[:side] ? "(#{activity[:side]})" : ""
      "#{activity[:method].capitalize} feeding #{side} • #{activity[:duration]} min"
    when "diaper"
      type = activity[:dirty] ? "Dirty" : "Wet"
      "#{type} diaper • #{activity[:color]}"
    when "sleep"
      "Sleep • #{activity[:duration]} min in #{activity[:location]}"
    when "pumping"
      "Pumping • #{activity[:total]}ml total"
    else
      "Unknown activity"
    end
  end

  def time_ago(time)
    diff = ((Time.current - time) / 60).to_i
    if diff < 60
      "#{diff}m ago"
    elsif diff < 1440
      "#{(diff / 60).to_i}h ago"
    else
      "#{(diff / 1440).to_i}d ago"
    end
  end
end
