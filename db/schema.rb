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

ActiveRecord::Schema[7.2].define(version: 2025_07_23_002348) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "detail"
    t.integer "action_type", default: 0, null: false
    t.integer "mastery_level", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_actions_on_user_id"
  end

  create_table "charts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_charts_on_user_id"
  end

  create_table "edges", force: :cascade do |t|
    t.bigint "source_node_id", null: false
    t.bigint "target_node_id", null: false
    t.bigint "chart_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chart_id"], name: "index_edges_on_chart_id"
    t.index ["source_node_id"], name: "index_edges_on_source_node_id"
    t.index ["target_node_id"], name: "index_edges_on_target_node_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.bigint "action_id", null: false
    t.bigint "chart_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_id"], name: "index_nodes_on_action_id"
    t.index ["chart_id"], name: "index_nodes_on_chart_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "actions", "users"
  add_foreign_key "charts", "users"
  add_foreign_key "edges", "charts"
  add_foreign_key "edges", "nodes", column: "source_node_id"
  add_foreign_key "edges", "nodes", column: "target_node_id"
  add_foreign_key "nodes", "actions"
  add_foreign_key "nodes", "charts"
end
