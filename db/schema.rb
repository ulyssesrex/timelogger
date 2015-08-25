# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150819172315) do

  create_table "grantholdings", force: :cascade do |t|
    t.integer  "grant_id"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.float    "required_hours"
  end

  add_index "grantholdings", ["grant_id"], name: "index_grantholdings_on_grant_id"
  add_index "grantholdings", ["user_id"], name: "index_grantholdings_on_user_id"

  create_table "grants", force: :cascade do |t|
    t.string   "name"
    t.text     "comments"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "grants", ["organization_id"], name: "index_grants_on_organization_id"

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
  end

  create_table "supervisions", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "supervisor_id"
    t.integer  "supervisee_id"
  end

  add_index "supervisions", ["supervisee_id"], name: "index_supervisions_on_supervisee_id"
  add_index "supervisions", ["supervisor_id"], name: "index_supervisions_on_supervisor_id"

  create_table "time_allocations", force: :cascade do |t|
    t.integer  "grantholding_id"
    t.integer  "timelog_id"
    t.datetime "start_time"
    t.text     "comments"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "end_time"
  end

  add_index "time_allocations", ["grantholding_id"], name: "index_time_allocations_on_grantholding_id"
  add_index "time_allocations", ["timelog_id"], name: "index_time_allocations_on_timelog_id"

  create_table "timelogs", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "comments"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "timelogs", ["user_id"], name: "index_timelogs_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "last_name"
    t.string   "position"
    t.boolean  "admin",             default: false
    t.datetime "start_date"
    t.integer  "organization_id"
    t.string   "password_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "activation_digest"
    t.string   "remember_digest"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_index "users", ["organization_id"], name: "index_users_on_organization_id"

end
