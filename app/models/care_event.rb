class CareEvent < ApplicationRecord
  FEED_KINDS = %w[feed].freeze
  DIAPER_KINDS = %w[diaper].freeze
  SLEEP_KINDS = %w[sleep].freeze
  KINDS = (FEED_KINDS + DIAPER_KINDS + SLEEP_KINDS).freeze
  FEED_MODES = %w[breast bottle_breastmilk formula].freeze
  FEED_SIDES = %w[left right both].freeze
  DIAPER_TYPES = %w[wet poop both].freeze

  belongs_to :baby
  belongs_to :user

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :started_at, presence: true
  validates :payload, presence: true, unless: :sleep?
  validates :feed_mode, presence: true, inclusion: { in: FEED_MODES }, if: :feed?
  validates :feed_side, inclusion: { in: FEED_SIDES }, allow_blank: true, if: :feed?
  validates :feed_amount_ml, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true, if: :feed?
  validates :feed_duration_min, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true, if: :feed?
  validates :diaper_type, presence: true, inclusion: { in: DIAPER_TYPES }, if: :diaper?
  validate :cannot_overlap_active_sleep, if: :sleep?, on: :create

  scope :chronological_desc, -> { order(started_at: :desc, id: :desc) }
  scope :for_kind, ->(kind) { where(kind: kind) }
  scope :started_on_or_before, ->(time) { where(started_at: ..time) }
  scope :active_sleep, -> { where(kind: "sleep", ended_at: nil) }

  def feed?
    kind == "feed"
  end

  def diaper?
    kind == "diaper"
  end

  def feed_mode
    payload["mode"]
  end

  def feed_side
    payload["side"]
  end

  def feed_amount_ml
    payload["amount_ml"]
  end

  def feed_duration_min
    payload["duration_min"]
  end

  def diaper_type
    return "both" if diaper_pee? && diaper_poop?
    return "wet" if diaper_pee?
    return "poop" if diaper_poop?

    nil
  end

  def diaper_pee?
    ActiveModel::Type::Boolean.new.cast(payload["pee"])
  end

  def diaper_poop?
    ActiveModel::Type::Boolean.new.cast(payload["poop"])
  end

  def diaper_color
    payload["color"]
  end

  def sleep?
    kind == "sleep"
  end

  def active_sleep?
    sleep? && ended_at.nil?
  end

  def completed_sleep?
    sleep? && ended_at.present?
  end

  def duration_minutes
    return nil unless sleep?
    end_time = ended_at || Time.current
    ((end_time - started_at) / 60).round
  end

  private
    def cannot_overlap_active_sleep
      return unless baby&.id

      existing = CareEvent.where(baby_id: baby.id, kind: "sleep", ended_at: nil).exists?
      if existing
        errors.add(:base, "Cannot start a new sleep while another is active")
      end
    end
end
