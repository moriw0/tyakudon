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

ActiveRecord::Schema[7.0].define(version: 2023_04_09_075729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ramen_shops", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "records", force: :cascade do |t|
    t.bigint "ramen_shop_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "elapsed_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ramen_shop_id"], name: "index_records_on_ramen_shop_id"
  end

  add_foreign_key "records", "ramen_shops"
end
