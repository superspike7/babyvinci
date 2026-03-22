class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email, with: ->(value) { normalize_email(value) }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def self.normalize_email(value)
    value.to_s.strip.downcase
  end
end
