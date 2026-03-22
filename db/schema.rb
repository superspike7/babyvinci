# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_03_22_170723) do
  create_table "activities", force: :cascade do |t|
    t.bigint "baby_id", null: false
    t.string "activity_type", null: false
    t.string "activity_typeable_type", null: false
    t.bigint "activity_typeable_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id", null: false
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["activity_typeable_type", "activity_typeable_id"], name: "activity_typeable_index"
    t.index ["activity_typeable_type", "activity_typeable_id"], name: "index_activities_on_activity_typeable"
    t.index ["baby_id"], name: "index_activities_on_baby_id"
    t.index ["family_id"], name: "index_activities_on_family_id"
  end

  create_table "babies", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name", null: false
    t.date "birth_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_babies_on_family_id"
  end

  create_table "diapers", force: :cascade do |t|
    t.string "diaper_type", default: "wet", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "family_code"
    t.index ["family_code"], name: "index_families_on_family_code", unique: true
  end

  create_table "feedings", force: :cascade do |t|
    t.string "feed_type", default: "breast", null: false
    t.integer "duration_minutes"
    t.string "side"
    t.integer "amount_ml"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sleeps", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "quality"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.datetime "invited_at"
    t.datetime "accepted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "activities", "babies"
  add_foreign_key "activities", "families"
  add_foreign_key "babies", "families"
  add_foreign_key "sessions", "users"
end
