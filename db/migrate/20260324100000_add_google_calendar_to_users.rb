class AddGoogleCalendarToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_access_token, :string
    add_column :users, :google_refresh_token, :string
    add_column :users, :google_token_expires_at, :datetime
    add_column :users, :google_calendar_email, :string
  end
end
