class BabyInvite < ApplicationRecord
  EXPIRY_WINDOW = 3.days

  belongs_to :baby
  belongs_to :invited_by_user, class_name: "User"
  belongs_to :accepted_by_user, class_name: "User", optional: true

  has_secure_token :token

  normalizes :email, with: ->(value) { User.normalize_email(value) }

  validates :email, presence: true
  validates :expires_at, presence: true
  validate :baby_has_open_parent_seat, on: :create
  validate :email_not_already_member, on: :create
  validate :baby_has_no_other_active_invite, on: :create

  before_validation :set_default_expiry, on: :create

  scope :active, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }

  def active?
    accepted_at.nil? && expires_at.future?
  end

  def matching_email?(value)
    email == User.normalize_email(value)
  end

  def accept!(user)
    transaction do
      reload
      raise ActiveRecord::RecordInvalid.new(self), self unless active?
      raise ActiveRecord::RecordInvalid.new(self), self unless matching_email?(user.email)

      baby.baby_memberships.find_or_create_by!(user: user) do |membership|
        membership.role = "parent"
      end

      update!(accepted_at: Time.current, accepted_by_user: user)
    end
  end

  private
    def set_default_expiry
      self.expires_at ||= EXPIRY_WINDOW.from_now
    end

    def baby_has_open_parent_seat
      return unless baby && baby.parent_limit_reached?

      errors.add(:base, "Both parent seats are already in use.")
    end

    def email_not_already_member
      return unless baby && email.present?
      return unless baby.users.where(email: email).exists?

      errors.add(:email, "is already part of this baby log")
    end

    def baby_has_no_other_active_invite
      return unless baby
      return unless baby.baby_invites.active.exists?

      errors.add(:base, "An invite is already waiting to be accepted.")
    end
end
