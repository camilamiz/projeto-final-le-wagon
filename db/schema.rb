# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_13_154728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorships", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "councillor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["councillor_id"], name: "index_authorships_on_councillor_id"
    t.index ["project_id"], name: "index_authorships_on_project_id"
  end

  create_table "councillors", force: :cascade do |t|
    t.string "name"
    t.string "party"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "presences", force: :cascade do |t|
    t.bigint "councillor_id"
    t.bigint "session_id"
    t.boolean "present"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["councillor_id"], name: "index_presences_on_councillor_id"
    t.index ["session_id"], name: "index_presences_on_session_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "subject"
    t.integer "chave"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "votings", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "councillor_id"
    t.bigint "session_id"
    t.boolean "vote"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["councillor_id"], name: "index_votings_on_councillor_id"
    t.index ["project_id"], name: "index_votings_on_project_id"
    t.index ["session_id"], name: "index_votings_on_session_id"
  end

  add_foreign_key "authorships", "councillors"
  add_foreign_key "authorships", "projects"
  add_foreign_key "presences", "councillors"
  add_foreign_key "presences", "sessions"
  add_foreign_key "votings", "councillors"
  add_foreign_key "votings", "projects"
  add_foreign_key "votings", "sessions"
end
