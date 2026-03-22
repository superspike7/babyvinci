class CreateCareEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :care_events do |t|
      t.references :baby, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.json :payload, null: false, default: {}

      t.timestamps
    end

    add_index :care_events, [ :baby_id, :started_at ]
    add_index :care_events, :kind
  end
end
