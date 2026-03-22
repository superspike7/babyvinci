class CareEvent < ApplicationRecord
  FEED_KINDS = %w[feed].freeze
  DIAPER_KINDS = %w[diaper].freeze
  KINDS = (FEED_KINDS + DIAPER_KINDS).freeze

  belongs_to :baby
  belongs_to :user

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :started_at, presence: true

  scope :most_recent_first, -> { order(started_at: :desc, created_at: :desc) }
  scope :for_kind, ->(kind) { where(kind: kind) }

  def feed?
    kind == "feed"
  end

  def diaper?
    kind == "diaper"
  end
end
