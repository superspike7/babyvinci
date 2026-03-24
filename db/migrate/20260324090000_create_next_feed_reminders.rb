class CreateNextFeedReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :next_feed_reminders do |t|
      t.references :baby, null: false, foreign_key: true, index: { unique: true }
      t.datetime :target_at, null: false

      t.timestamps
    end
  end
end
