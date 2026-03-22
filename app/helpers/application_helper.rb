module ApplicationHelper
  def secondary_nav_link_to(name, path)
    link_to(
      name,
      path,
      class: "inline-flex min-h-11 items-center text-sm font-semibold text-vinci-accent underline decoration-vinci-accent/60 decoration-2 underline-offset-4 transition-colors hover:text-vinci-ink hover:decoration-vinci-accent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-vinci-accent/25"
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
    else
      event.kind.capitalize
    end
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

  private
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
end
