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

ActiveRecord::Schema[7.2].define(version: 2025_07_28_044114) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "charts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_charts_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_charts_on_user_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.bigint "chart_id"
    t.bigint "technique_id"
    t.string "ancestry", null: false, collation: "C"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_nodes_on_ancestry"
    t.index ["chart_id"], name: "index_nodes_on_chart_id"
    t.index ["technique_id"], name: "index_nodes_on_technique_id"
  end

  create_table "techniques", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", null: false
    t.string "english_name"
    t.boolean "is_submission", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
    t.index ["user_id", "name"], name: "index_techniques_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_techniques_on_user_id"
  end

  create_table "transitions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "from_technique_id", null: false
    t.bigint "to_technique_id", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_technique_id"], name: "index_transitions_on_from_technique_id"
    t.index ["to_technique_id"], name: "index_transitions_on_to_technique_id"
    t.index ["user_id"], name: "index_transitions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.string "name", default: "", null: false
    t.string "image"
    t.text "quick_memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "charts", "users"
  add_foreign_key "nodes", "charts"
  add_foreign_key "nodes", "techniques"
  add_foreign_key "techniques", "users"
  add_foreign_key "transitions", "techniques", column: "from_technique_id"
  add_foreign_key "transitions", "techniques", column: "to_technique_id"
  add_foreign_key "transitions", "users"
end
