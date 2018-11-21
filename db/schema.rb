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

ActiveRecord::Schema.define(version: 2018_11_21_180814) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "councillor_id"
    t.boolean "present"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "att_date"
    t.string "party"
    t.index ["councillor_id"], name: "index_attendances_on_councillor_id"
  end

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
    t.integer "chave"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "photo"
  end

  create_table "projects", force: :cascade do |t|
    t.string "chave"
    t.string "tipo"
    t.integer "numero"
    t.integer "ano"
    t.string "ementa"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

  create_table "votings", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "councillor_id"
    t.boolean "vote"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sessao"
    t.date "vote_date"
    t.string "tipo"
    t.string "materia"
    t.string "ementa"
    t.string "rodape"
    t.string "partido"
    t.string "resultado"
    t.integer "chave"
    t.index ["councillor_id"], name: "index_votings_on_councillor_id"
    t.index ["project_id"], name: "index_votings_on_project_id"
  end

  add_foreign_key "attendances", "councillors"
  add_foreign_key "authorships", "councillors"
  add_foreign_key "authorships", "projects"
  add_foreign_key "votings", "councillors"
  add_foreign_key "votings", "projects"
end
