class Guidance
  # Evidence-based guidance from AAP (American Academy of Pediatrics) and Stanford Medicine
  # Sources:
  # - AAP HealthyChildren.org: "How Often and How Much Should Your Baby Eat?" (Dr. Sanjeev Jain, MD, FAAP & Dr. Maya Bunik, MD, MPH, FAAP)
  # - Stanford Medicine Children's Health: "Newborn Sleep Patterns"
  # - AAP Well-Child Visit Schedule
  #
  # PRD Compliance:
  # - Short, supportive, non-diagnostic copy
  # - No medical advice or dosage recommendations (per pediatrician discretion)
  # - Focus on normal patterns and reassurance
  CONTENT = {
    # Newborn (0-2 weeks) - Source: AAP/Stanford
    newborn: {
      max_days: 14,
      notes: [
        "Breastfed babies typically feed 10-12 times per 24 hours. Bottle-fed babies usually eat every 2-3 hours. Both are normal.",
        "Newborns sleep about 16-17 hours per day, waking every few hours to eat. This is expected."
      ]
    },
    # Early weeks (2-6 weeks) - Source: AAP
    early_weeks: {
      max_days: 42,
      notes: [
        "Cluster feeding (frequent short feeds, often in the evening) is common and helps build milk supply.",
        "Crying is a late sign of hunger. Early cues: lip licking, rooting, putting hands to mouth."
      ]
    },
    # Six week mark (6-8 weeks) - Source: AAP
    six_weeks: {
      max_days: 56,
      notes: [
        "Around 6 weeks, many babies have a growth spurt and may want to feed more often. This is temporary.",
        "You're doing better than you think you are."
      ]
    },
    # Two months (8-12 weeks) - Source: AAP/Stanford
    two_months: {
      max_days: 84,
      notes: [
        "First intentional smiles often appear around now. Those social smiles are coming.",
        "Short naps of 20-45 minutes are developmentally normal at this age."
      ]
    },
    # Three months (12-16 weeks) - Source: AAP/Stanford
    three_months: {
      max_days: 112,
      notes: [
        "Some babies start sleeping longer stretches at night around now. Some don't. Both are completely normal.",
        "Tummy time can be brief and frequent—a few minutes here and there adds up over the day."
      ]
    },
    # Four months (16-20 weeks) - Source: AAP
    four_months: {
      max_days: 140,
      notes: [
        "The '4-month sleep regression' is a developmental leap. It is temporary and passes.",
        "4-month well-visit with your pediatrician coming up."
      ]
    },
    # Five months (20-24 weeks) - Source: AAP
    five_months: {
      max_days: 168,
      notes: [
        "Rolling may start now. Keep a hand nearby during diaper changes on elevated surfaces.",
        "Babies explore through their mouths. Keep small objects out of reach."
      ]
    },
    # Six months (24-28 weeks) - Source: AAP
    six_months: {
      max_days: 196,
      notes: [
        "6-month well-visit with vaccines and growth check. Discuss starting solids if you haven't already.",
        "Some babies are ready for solids around now. Others need more time. Follow your baby's cues."
      ]
    }
  }.freeze

  MAX_NOTES = 2

  class << self
    def for_age_in_days(days)
      return [] if days.negative?

      bucket = bucket_for_age(days)
      return [] unless bucket

      bucket[:notes].first(MAX_NOTES)
    end

    def bucket_for_age(days)
      return nil if days.negative?

      CONTENT.find { |_key, bucket| days <= bucket[:max_days] }&.last
    end

    def all_buckets
      CONTENT.keys
    end
  end
end
