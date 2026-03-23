class CreateBabyInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :baby_invites do |t|
      t.references :baby, null: false, foreign_key: true
      t.references :invited_by_user, null: false, foreign_key: { to_table: :users }
      t.references :accepted_by_user, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :baby_invites, :token, unique: true
  end
end
