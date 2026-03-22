class Baby < ApplicationRecord
  attr_accessor :birth_date, :birth_time

  belongs_to :created_by_user, class_name: "User", optional: true
  has_many :baby_memberships, dependent: :destroy
  has_many :care_events, dependent: :destroy
  has_many :users, through: :baby_memberships

  validates :first_name, presence: true
  validates :birth_at, presence: true
end
