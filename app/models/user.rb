class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :baby_memberships, dependent: :destroy
  has_many :care_events, dependent: :destroy
  has_many :sent_baby_invites, class_name: "BabyInvite", foreign_key: :invited_by_user_id, dependent: :destroy
  has_many :accepted_baby_invites, class_name: "BabyInvite", foreign_key: :accepted_by_user_id, dependent: :nullify
  has_many :babies, through: :baby_memberships

  normalizes :email, with: ->(value) { normalize_email(value) }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def self.normalize_email(value)
    value.to_s.strip.downcase
  end

  def google_calendar_connected?
    google_access_token.present?
  end

  def clear_google_calendar_connection!
    update!(
      google_access_token: nil,
      google_refresh_token: nil,
      google_token_expires_at: nil,
      google_calendar_email: nil
    )
  end
end
