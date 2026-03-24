class AddGoogleCalendarEventIdToNextFeedReminders < ActiveRecord::Migration[8.0]
  def up
    add_column :next_feed_reminders, :google_calendar_event_id, :string
    add_column :next_feed_reminders, :calendar_sync_failed_at, :datetime
    add_column :next_feed_reminders, :calendar_owner_user_id, :integer
    add_foreign_key :next_feed_reminders, :users, column: :calendar_owner_user_id

    add_index :next_feed_reminders, :google_calendar_event_id
    add_index :next_feed_reminders, :calendar_sync_failed_at
  end

  def down
    remove_index :next_feed_reminders, :calendar_sync_failed_at, if_exists: true
    remove_index :next_feed_reminders, :google_calendar_event_id, if_exists: true
    remove_foreign_key :next_feed_reminders, :users, column: :calendar_owner_user_id, if_exists: true
    remove_column :next_feed_reminders, :calendar_owner_user_id
    remove_column :next_feed_reminders, :calendar_sync_failed_at
    remove_column :next_feed_reminders, :google_calendar_event_id
  end
end
