class CareEvent < ApplicationRecord
  FEED_KINDS = %w[feed].freeze
  DIAPER_KINDS = %w[diaper].freeze
  KINDS = (FEED_KINDS + DIAPER_KINDS).freeze
  FEED_MODES = %w[breast bottle_breastmilk formula].freeze
  FEED_SIDES = %w[left right both].freeze

  belongs_to :baby
  belongs_to :user

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :started_at, presence: true
  validates :payload, presence: true
  validates :feed_mode, presence: true, inclusion: { in: FEED_MODES }, if: :feed?
  validates :feed_side, inclusion: { in: FEED_SIDES }, allow_blank: true, if: :feed?
  validates :feed_amount_ml, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true, if: :feed?
  validates :feed_duration_min, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true, if: :feed?

  scope :chronological_desc, -> { order(started_at: :desc, id: :desc) }
  scope :for_kind, ->(kind) { where(kind: kind) }
  scope :started_on_or_before, ->(time) { where(started_at: ..time) }

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
end
