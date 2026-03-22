class BabyCreator
  def self.create!(user:, first_name:, birth_at:)
    Baby.transaction do
      baby = Baby.create!(first_name:, birth_at:, created_by_user: user)
      baby.baby_memberships.create!(user:, role: "parent")
      baby
    end
  end
end
