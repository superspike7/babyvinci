class CreateBabyMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :baby_memberships do |t|
      t.references :baby, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "parent"

      t.timestamps
    end

    add_index :baby_memberships, [ :baby_id, :user_id ], unique: true
  end
end
