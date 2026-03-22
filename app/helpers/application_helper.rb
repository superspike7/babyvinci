module ApplicationHelper
  def baby_age_label(baby)
    "Day #{baby_age_in_days(baby)}"
  end

  def baby_age_in_words(baby)
    days = baby_age_in_days(baby)

    return "less than a day old" if days.zero?
    return "1 day old" if days == 1

    "#{days} days old"
  end

  private
    def baby_age_in_days(baby)
      ((Time.zone.today - baby.birth_at.to_date).to_i + 1).clamp(0, Float::INFINITY)
    end
end
