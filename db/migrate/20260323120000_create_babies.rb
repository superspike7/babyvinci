class CreateBabies < ActiveRecord::Migration[8.0]
  def change
    if table_exists?(:babies)
      rename_column :babies, :name, :first_name if column_exists?(:babies, :name)

      if column_exists?(:babies, :birth_date)
        rename_column :babies, :birth_date, :birth_at
        change_column :babies, :birth_at, :datetime
      end

      remove_reference :babies, :family, foreign_key: true if column_exists?(:babies, :family_id)
      add_reference :babies, :created_by_user, foreign_key: { to_table: :users } unless column_exists?(:babies, :created_by_user_id)

      reversible do |dir|
        dir.up do
          execute <<~SQL.squish
            UPDATE babies
            SET created_by_user_id = (SELECT id FROM users ORDER BY id LIMIT 1)
            WHERE created_by_user_id IS NULL
          SQL
        end
      end

      change_column_null :babies, :first_name, false
      change_column_null :babies, :birth_at, false
      change_column_null :babies, :created_by_user_id, false
    else
      create_table :babies do |t|
        t.string :first_name, null: false
        t.datetime :birth_at, null: false
        t.references :created_by_user, null: false, foreign_key: { to_table: :users }

        t.timestamps
      end
    end
  end
end
