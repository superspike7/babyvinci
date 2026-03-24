class NextFeedReminder < ApplicationRecord
  belongs_to :baby
  belongs_to :calendar_owner, class_name: "User", optional: true

  validates :target_at, presence: true
  validates :baby_id, uniqueness: true
end
