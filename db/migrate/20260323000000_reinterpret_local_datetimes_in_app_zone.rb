class ReinterpretLocalDatetimesInAppZone < ActiveRecord::Migration[8.0]
  class MigrationBaby < ApplicationRecord
    self.table_name = "babies"
  end

  class MigrationCareEvent < ApplicationRecord
    self.table_name = "care_events"
  end

  def up
    zone = ActiveSupport::TimeZone[Rails.application.config.time_zone] || ActiveSupport::TimeZone["UTC"]

    MigrationBaby.find_each do |baby|
      baby.update_columns(birth_at: reinterpret(baby.read_attribute_before_type_cast("birth_at"), zone), updated_at: Time.current)
    end

    MigrationCareEvent.find_each do |event|
      event.update_columns(
        started_at: reinterpret(event.read_attribute_before_type_cast("started_at"), zone),
        ended_at: reinterpret(event.read_attribute_before_type_cast("ended_at"), zone),
        updated_at: Time.current
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private
    def reinterpret(raw_timestamp, zone)
      return if raw_timestamp.blank?

      zone.strptime(raw_timestamp, "%Y-%m-%d %H:%M:%S").utc
    end
end
