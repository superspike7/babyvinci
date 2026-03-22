class CreateUsers < ActiveRecord::Migration[8.0]
  def up
    if table_exists?(:users)
      migrate_existing_users_table
    else
      create_table :users do |t|
        t.string :name, null: false
        t.string :email, null: false
        t.string :password_digest, null: false
        t.datetime :invited_at
        t.datetime :accepted_at

        t.timestamps
      end
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email, unique: true)
  end

  def down
    drop_table :users if table_exists?(:users)
  end

  private
    def migrate_existing_users_table
      rename_column :users, :encrypted_password, :password_digest if column_exists?(:users, :encrypted_password)

      add_column :users, :name, :string unless column_exists?(:users, :name)
      add_column :users, :invited_at, :datetime unless column_exists?(:users, :invited_at)
      add_column :users, :accepted_at, :datetime unless column_exists?(:users, :accepted_at)

      remove_column :users, :family_id, :bigint if column_exists?(:users, :family_id)
      remove_column :users, :reset_password_token, :string if column_exists?(:users, :reset_password_token)
      remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
      remove_column :users, :remember_created_at, :datetime if column_exists?(:users, :remember_created_at)

      change_column_default :users, :email, from: "", to: nil if column_exists?(:users, :email)
      change_column_default :users, :password_digest, from: "", to: nil if column_exists?(:users, :password_digest)

      execute <<~SQL.squish
        UPDATE users
        SET name = ''
        WHERE name IS NULL
      SQL

      change_column_null :users, :name, false
      change_column_null :users, :email, false
      change_column_null :users, :password_digest, false
    end
end
