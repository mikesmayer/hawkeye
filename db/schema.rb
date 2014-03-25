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

ActiveRecord::Schema.define(version: 20140325003821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approved_users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "ftp_connects", force: true do |t|
    t.string   "server"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_discount_items", force: true do |t|
    t.boolean  "auto_apply"
    t.float    "discount_amount"
    t.integer  "discount_item_id"
    t.integer  "menu_item_id"
    t.integer  "pos_ticket_id"
    t.integer  "pos_ticket_item_id"
    t.string   "reason_text"
    t.integer  "ticket_id"
    t.integer  "ticket_item_id"
    t.float    "ticket_item_price"
    t.time     "when"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_discounts", force: true do |t|
    t.boolean  "active"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_meal_count_rules", force: true do |t|
    t.integer  "menu_item_id"
    t.time     "start_date"
    t.time     "end_date"
    t.integer  "meal_modifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_menu_item_groups", force: true do |t|
    t.string   "name"
    t.integer  "default_meal_modifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_menu_items", force: true do |t|
    t.float    "gross_price"
    t.integer  "menu_item_group_id"
    t.string   "name"
    t.integer  "recipe_id"
    t.integer  "revenue_group_id"
    t.boolean  "count_meal"
    t.integer  "count_meal_modifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_revenue_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_ticket_items", force: true do |t|
    t.float    "auto_discount"
    t.float    "gross_price"
    t.integer  "item_qty"
    t.float    "manual_discount"
    t.integer  "menu_item_group_id"
    t.integer  "menu_item_id"
    t.float    "net_price"
    t.integer  "pos_ticket_id"
    t.integer  "pos_ticket_item_id"
    t.integer  "revenue_group_id"
    t.integer  "ticket_id"
    t.integer  "meal_for_meal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_tickets", force: true do |t|
    t.float    "auto_discount"
    t.integer  "customer_id"
    t.float    "gross_price"
    t.integer  "meal_for_meal"
    t.float    "manual_discount"
    t.float    "net_price"
    t.datetime "ticket_close_time"
    t.datetime "ticket_open_time"
    t.integer  "pos_ticket_id"
    t.string   "customer_phone"
    t.float    "discount_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restaurants", force: true do |t|
    t.string   "name",                null: false
    t.integer  "bek_customer_number"
    t.string   "soap_url"
    t.string   "soap_endpoint"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "name"
    t.string   "fname"
    t.string   "lname"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
