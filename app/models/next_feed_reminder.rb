class NextFeedReminder < ApplicationRecord
  belongs_to :baby

  validates :target_at, presence: true
  validates :baby_id, uniqueness: true
end
