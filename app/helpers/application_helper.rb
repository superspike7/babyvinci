module ApplicationHelper
  def secondary_nav_link_to(name, path)
    link_to(
      name,
      path,
      class: "inline-flex min-h-11 items-center text-sm font-semibold text-vinci-accent underline decoration-vinci-accent/60 decoration-2 underline-offset-4 transition-colors hover:text-vinci-ink hover:decoration-vinci-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-vinci-accent/25"
    )
  end

  def primary_nav_link_to(name, path, current: false)
    link_to(
      name,
      path,
      aria: current ? { current: "page" } : {},
      class: [
        "flex min-h-11 items-center justify-center rounded-full px-3 py-3 text-sm font-semibold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-vinci-accent/25",
        current ? "bg-vinci-base text-vinci-ink shadow-sm" : "text-vinci-text hover:bg-vinci-base/80 hover:text-vinci-ink"
      ].join(" ")
    )
  end

  def primary_action_link_to(name, path, style: :primary)
    style_classes = if style == :secondary
      "border border-vinci-border bg-vinci-base text-vinci-ink hover:border-vinci-accent hover:text-vinci-accent"
    else
      "bg-vinci-accent text-vinci-surface hover:bg-vinci-ink"
    end

    link_to(
      name,
      path,
      class: [
        "flex min-h-12 items-center justify-center rounded-full px-4 py-4 text-base font-semibold transition focus:outline-none focus:ring-2 focus:ring-vinci-accent/20",
        style_classes
      ].join(" ")
    )
  end

  def baby_age_label(baby)
    "Day #{baby_age_in_days(baby)}"
  end

  def timeline_day_label(date)
    date.strftime("%A, %B %-d")
  end

  def baby_age_in_words(baby)
    days = baby_age_in_days(baby)

    return "less than a day old" if days.zero?
    return "1 day old" if days == 1

    "#{days} days old"
  end

  def care_event_name(event)
    return "Safety check" if event.concern?

    event.kind.capitalize
  end

  def care_event_time(event)
    event.started_at.strftime("%-I:%M %p").downcase.sub("am", "AM").sub("pm", "PM")
  end

  def care_event_detail(event)
    if event.feed?
      feed_detail(event)
    elsif event.diaper?
      diaper_detail(event)
    elsif event.sleep?
      sleep_detail(event)
    elsif event.concern?
      concern_detail(event)
    else
      event.kind.capitalize
    end
  end

  def sleep_detail(event)
    return "Sleeping now" if event.active_sleep?

    duration = event.duration_minutes
    return "Sleep ended" unless duration

    sleep_duration_label(duration)
  end

  def care_event_author(event)
    "Logged by #{event.user.name}"
  end

  def feed_mode_label(mode)
    case mode
    when "bottle_breastmilk"
      "Breastmilk bottle"
    else
      mode.to_s.humanize
    end
  end

  def diaper_type_label(diaper_type)
    case diaper_type
    when "wet"
      "Wet"
    when "poop"
      "Poop"
    when "both"
      "Both"
    else
      diaper_type.to_s.humanize
    end
  end

  def recent_timeline_title(care_events)
    care_events.any? ? nil : "Nothing logged yet"
  end

  def latest_care_event_label(event)
    return "No #{yield} yet" unless event

    care_event_elapsed_label(event.started_at)
  end

  def care_event_elapsed_label(time)
    return "just now" if time > Time.current

    "#{time_ago_in_words(time)} ago"
  end

  def next_feed_reminder_label(reminder)
    return unless reminder&.target_at

    reminder.target_at.strftime("%-I:%M %p").downcase.sub("am", "AM").sub("pm", "PM")
  end

  def next_feed_reminder_state_label(reminder)
    return unless reminder&.target_at

    reminder.target_at <= Time.current ? "Overdue" : "Scheduled"
  end

  def next_feed_reminder_compact_status(reminder)
    return unless reminder&.target_at

    delta = reminder.target_at - Time.current
    prefix = delta.negative? || delta.zero? ? "OVERDUE" : "IN"

    "#{prefix} #{compact_duration_label(delta.abs)}"
  end

  def next_feed_reminder_input_value(reminder)
    reminder&.target_at&.strftime("%Y-%m-%dT%H:%M")
  end

  def sleep_duration_label(minutes)
    return nil unless minutes

    hours, mins = minutes.divmod(60)

    if hours.positive? && mins.positive?
      "#{hours} hr #{mins} min"
    elsif hours.positive?
      "#{hours} hr"
    else
      "#{mins} min"
    end
  end

  def sleep_state_label(active_sleep)
    return "No sleep yet" unless active_sleep

    if active_sleep.active_sleep?
      "Sleeping now"
    else
      sleep_duration_label(active_sleep.duration_minutes)
    end
  end

  def sleep_detail_label(event)
    return nil unless event&.sleep?

    if event.active_sleep?
      "Started #{care_event_elapsed_label(event.started_at)}"
    else
      time_label = event.ended_at.strftime("%-I:%M %p").downcase.sub("am", "AM").sub("pm", "PM")
      day_label = event.ended_at.today? ? "Today" : "Yesterday"
      "#{day_label} at #{time_label}"
    end
  end

  private
    def compact_duration_label(seconds)
      total_minutes = (seconds / 60.0).round
      return "NOW" if total_minutes <= 0

      hours, minutes = total_minutes.divmod(60)

      if hours.positive?
        [ "#{hours}H", ("#{minutes}M" if minutes.positive?) ].compact.join(" ")
      else
        "#{minutes}M"
      end
    end

    def baby_age_in_days(baby)
      ((Time.zone.today - baby.birth_at.to_date).to_i + 1).clamp(0, Float::INFINITY)
    end

    def feed_detail(event)
      parts = [ feed_mode_label(event.payload["mode"]) ]
      parts << "#{event.payload["amount_ml"]} ml" if event.payload["amount_ml"].present?
      parts << "#{event.payload["duration_min"]} min" if event.payload["duration_min"].present?
      parts.join(", ")
    end

    def diaper_detail(event)
      base = []
      base << "Wet" if event.diaper_pee?
      base << "stool" if event.diaper_poop?

      detail = base.presence&.join(" + ") || "Diaper"
      return detail if event.diaper_color.blank?

      "#{detail}, #{event.diaper_color}"
    end

    def concern_detail(event)
      flow_title = event.payload["flow_title"] || "Concern"
      disposition = event.concern_disposition
      disposition_label = ConcernFlow.disposition_label(disposition) || disposition.to_s.humanize

      "#{flow_title} — #{disposition_label}"
    end
end
