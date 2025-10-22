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

ActiveRecord::Schema[7.2].define(version: 2025_10_21_031416) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chart_presets", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_chart_presets_on_name", unique: true
  end

  create_table "charts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chart_preset_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chart_preset_id"], name: "index_charts_on_chart_preset_id"
    t.index ["user_id", "name"], name: "index_charts_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_charts_on_user_id"
  end

  create_table "edge_presets", force: :cascade do |t|
    t.bigint "from_id", null: false
    t.bigint "to_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_id"], name: "index_edge_presets_on_from_id"
    t.index ["to_id"], name: "index_edge_presets_on_to_id"
  end

  create_table "edges", force: :cascade do |t|
    t.bigint "from_id", null: false
    t.bigint "to_id", null: false
    t.integer "count", default: 0, null: false
    t.integer "flow", default: 0, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "trigger"
    t.index ["from_id", "to_id", "flow"], name: "index_edges_on_from_id_and_to_id_and_flow", unique: true
    t.index ["from_id"], name: "index_edges_on_from_id"
    t.index ["to_id"], name: "index_edges_on_to_id"
  end

  create_table "node_presets", force: :cascade do |t|
    t.bigint "chart_preset_id", null: false
    t.bigint "technique_preset_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.index ["chart_preset_id"], name: "index_node_presets_on_chart_preset_id"
    t.index ["technique_preset_id"], name: "index_node_presets_on_technique_preset_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.bigint "chart_id"
    t.bigint "technique_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.index ["chart_id"], name: "index_nodes_on_chart_id"
    t.index ["technique_id"], name: "index_nodes_on_technique_id"
  end

  create_table "technique_presets", force: :cascade do |t|
    t.string "name_ja", null: false
    t.string "name_en", null: false
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_technique_presets_on_name_en", unique: true
    t.index ["name_ja"], name: "index_technique_presets_on_name_ja", unique: true
  end

  create_table "techniques", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "technique_preset_id"
    t.string "name_ja", null: false
    t.string "name_en", null: false
    t.integer "category"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["technique_preset_id"], name: "index_techniques_on_technique_preset_id"
    t.index ["user_id", "name_en"], name: "index_techniques_on_user_id_and_name_en", unique: true
    t.index ["user_id", "name_ja"], name: "index_techniques_on_user_id_and_name_ja", unique: true
    t.index ["user_id"], name: "index_techniques_on_user_id"
  end

  create_table "transitions", force: :cascade do |t|
    t.bigint "from_id", null: false
    t.bigint "to_id", null: false
    t.string "trigger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_id", "to_id"], name: "index_transitions_on_from_id_and_to_id", unique: true
    t.index ["from_id"], name: "index_transitions_on_from_id"
    t.index ["to_id"], name: "index_transitions_on_to_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.string "name", default: "", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "charts", "chart_presets"
  add_foreign_key "charts", "users"
  add_foreign_key "edge_presets", "node_presets", column: "from_id"
  add_foreign_key "edge_presets", "node_presets", column: "to_id"
  add_foreign_key "edges", "nodes", column: "from_id"
  add_foreign_key "edges", "nodes", column: "to_id"
  add_foreign_key "node_presets", "chart_presets"
  add_foreign_key "node_presets", "technique_presets"
  add_foreign_key "nodes", "charts"
  add_foreign_key "nodes", "techniques"
  add_foreign_key "techniques", "technique_presets"
  add_foreign_key "techniques", "users"
  add_foreign_key "transitions", "techniques", column: "from_id"
  add_foreign_key "transitions", "techniques", column: "to_id"
end
