class NextFeedRemindersController < ApplicationController
  before_action :require_current_baby

  def create
    @next_feed_reminder = current_baby.next_feed_reminder || current_baby.build_next_feed_reminder
    @next_feed_reminder.target_at = reminder_target_at

    if @next_feed_reminder.save
      sync_calendar
      redirect_to today_path, notice: reminder_notice(@next_feed_reminder.previously_new_record?)
    else
      load_today_state
      render "home/show", status: :unprocessable_entity
    end
  end

  def update
    @next_feed_reminder = current_baby.next_feed_reminder || current_baby.build_next_feed_reminder
    @next_feed_reminder.target_at = reminder_target_at

    if @next_feed_reminder.save
      sync_calendar
      redirect_to today_path, notice: "Next feed reminder updated."
    else
      load_today_state
      render "home/show", status: :unprocessable_entity
    end
  end

  def destroy
    if current_baby.next_feed_reminder
      clear_calendar(current_baby.next_feed_reminder)
      current_baby.next_feed_reminder.destroy
    end

    redirect_to today_path, notice: "Next feed reminder cleared."
  end

  private
    FEED_LIKELY_SOON_THRESHOLD = HomeController::FEED_LIKELY_SOON_THRESHOLD
    DIAPER_CHECK_THRESHOLD = HomeController::DIAPER_CHECK_THRESHOLD

    def reminder_params
      params.require(:next_feed_reminder).permit(:target_at)
    end

    def reminder_target_at
      if preset_minutes.present?
        return Time.current + preset_minutes.minutes
      end

      value = reminder_params[:target_at]
      return nil if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end

    def preset_minutes
      minutes = params[:preset_minutes].to_i
      minutes if [ 30, 60, 120, 180 ].include?(minutes)
    end

    def require_current_baby
      redirect_to new_baby_path unless current_baby
    end

    def load_today_state
      @recent_care_events = visible_care_events.limit(8)
      @last_feed = latest_started_event_for("feed")
      @last_diaper = latest_started_event_for("diaper")
      @active_sleep = current_baby.care_events.active_sleep.first
      @last_sleep = latest_started_event_for("sleep")
      set_today_totals
      @today_guidance = build_today_guidance
      @guidance_notes = Guidance.for_age_in_days(baby_age_in_days(current_baby))
    end

    def set_today_totals
      today_events = visible_care_events.where(started_at: today_window).to_a
      today_diapers = today_events.select(&:diaper?)

      @today_feed_count = today_events.count(&:feed?)
      @today_wet_diaper_count = today_diapers.count(&:diaper_pee?)
      @today_stool_diaper_count = today_diapers.count(&:diaper_poop?)
      @today_sleep_total_minutes = today_sleep_total_minutes
    end

    def today_window
      Time.current.beginning_of_day..(Time.current + HomeController::VISIBLE_EVENT_SKEW)
    end

    def today_sleep_total_minutes
      day_start = Time.current.beginning_of_day
      now = Time.current

      total_seconds = current_baby.care_events
                                  .for_kind("sleep")
                                  .where("started_at < ?", now)
                                  .where("ended_at IS NULL OR ended_at > ?", day_start)
                                  .sum do |sleep_event|
        overlap_start = [ sleep_event.started_at, day_start ].max
        overlap_end = [ sleep_event.ended_at || now, now ].min

        [ overlap_end - overlap_start, 0 ].max
      end

      (total_seconds / 60.0).round
    end

    def build_today_guidance
      return active_sleep_guidance if @active_sleep
      return feed_guidance if feed_likely_soon?
      return diaper_guidance if diaper_check_may_be_due?
      return recent_feed_guidance if @last_feed
      return recent_diaper_guidance if @last_diaper

      {
        eyebrow: "Right now",
        headline: "Today is still quiet",
        support: "Log the first feed, diaper, or sleep when you're ready."
      }
    end

    def active_sleep_guidance
      {
        eyebrow: "Right now",
        headline: "Sleeping for #{helpers.sleep_duration_label(@active_sleep.duration_minutes)}",
        support: "Last sleep was #{helpers.precise_elapsed_label(@last_sleep.started_at)}",
        sleep_started_at: @active_sleep.started_at.to_i
      }
    end

    def feed_guidance
      {
        eyebrow: "Right now",
        headline: "Feed likely soon",
        support: "Last feed was #{helpers.precise_elapsed_label(@last_feed.started_at)}"
      }
    end

    def diaper_guidance
      {
        eyebrow: "Right now",
        headline: "Diaper check may be due",
        support: "Last diaper was #{helpers.precise_elapsed_label(@last_diaper.started_at)}"
      }
    end

    def recent_feed_guidance
      {
        eyebrow: "Right now",
        headline: "Last feed was #{helpers.precise_elapsed_label(@last_feed.started_at)}",
        support: @last_diaper ? "Last diaper was #{helpers.precise_elapsed_label(@last_diaper.started_at)}" : "No diaper logged yet."
      }
    end

    def recent_diaper_guidance
      {
        eyebrow: "Right now",
        headline: "Last diaper was #{helpers.precise_elapsed_label(@last_diaper.started_at)}",
        support: @last_feed ? "Last feed was #{helpers.precise_elapsed_label(@last_feed.started_at)}" : "No feed logged yet."
      }
    end

    def feed_likely_soon?
      @last_feed.present? && @last_feed.started_at <= Time.current - FEED_LIKELY_SOON_THRESHOLD
    end

    def diaper_check_may_be_due?
      @last_diaper.present? && @last_diaper.started_at <= Time.current - DIAPER_CHECK_THRESHOLD
    end

    def baby_age_in_days(baby)
      elapsed_seconds = Time.current - baby.birth_at
      (elapsed_seconds / 1.day).floor.clamp(0, Float::INFINITY)
    end

    def visible_care_events
      current_baby.care_events.includes(:user).started_on_or_before(HomeController::VISIBLE_EVENT_SKEW.from_now).chronological_desc
    end

    def latest_started_event_for(kind)
      visible_care_events.for_kind(kind).first
    end

    def reminder_notice(created)
      created ? "Next feed reminder set." : "Next feed reminder updated."
    end

    def sync_calendar
      owner = @next_feed_reminder.calendar_owner || Current.user
      GoogleCalendarSyncService.sync_reminder(
        reminder: @next_feed_reminder,
        creating_user: owner
      )
    end

    def clear_calendar(reminder)
      GoogleCalendarSyncService.clear_reminder(
        reminder: reminder,
        creating_user: Current.user
      )
    end
end
