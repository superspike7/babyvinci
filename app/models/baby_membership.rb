class BabyMembership < ApplicationRecord
  belongs_to :baby
  belongs_to :user

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :baby_id }
end
