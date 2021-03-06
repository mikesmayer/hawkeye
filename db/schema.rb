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

ActiveRecord::Schema.define(version: 20141228155719) do

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

  create_table "job_logs", force: true do |t|
    t.string   "job_type"
    t.datetime "date_run"
    t.string   "folder_name"
    t.string   "file_name"
    t.string   "method_name"
    t.string   "model_name"
    t.string   "error_ids"
    t.integer  "num_processed"
    t.integer  "num_errors"
    t.integer  "num_updated"
    t.integer  "num_created"
  end

  create_table "one_time_donations", force: true do |t|
    t.string   "description"
    t.float    "amount"
    t.float    "meals"
    t.date     "deposit_date"
    t.integer  "restaurant_id"
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
    t.float    "meal_modifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_revenue_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "p42_ticket_items", force: true do |t|
    t.integer  "pos_ticket_item_id"
    t.integer  "pos_ticket_id"
    t.integer  "menu_item_id"
    t.integer  "pos_category_id"
    t.integer  "pos_revenue_class_id"
    t.integer  "customer_original_id"
    t.float    "quantity"
    t.float    "net_price"
    t.float    "discount_total"
    t.float    "item_menu_price"
    t.float    "choice_additions_total"
    t.datetime "ticket_close_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "meal_for_meal"
  end

  add_index "p42_ticket_items", ["pos_ticket_item_id"], name: "index_p42_ticket_items_on_pos_ticket_item_id", unique: true, using: :btree

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
    t.string   "ticket_close_time_string"
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

  create_table "tacos_meal_count_rules", force: true do |t|
    t.integer  "menu_item_id"
    t.float    "meal_modifier"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tacos_menu_item_groups", force: true do |t|
    t.string   "name"
    t.integer  "default_meal_modifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tacos_menu_items", force: true do |t|
    t.integer  "menu_item_group_id"
    t.string   "name"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tacos_ticket_items", force: true do |t|
    t.integer  "pos_ticket_item_id"
    t.integer  "pos_ticket_id"
    t.integer  "menu_item_id"
    t.integer  "pos_category_id"
    t.integer  "pos_revenue_class_id"
    t.float    "quantity"
    t.float    "net_price"
    t.float    "discount_total"
    t.float    "item_menu_price"
    t.datetime "ticket_close_time"
    t.float    "meal_for_meal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "void"
    t.date     "dob"
  end

  add_index "tacos_ticket_items", ["pos_ticket_item_id"], name: "index_tacos_ticket_items_on_pos_ticket_item_id", using: :btree

  create_table "tip_jar_donations", force: true do |t|
    t.float    "amount"
    t.float    "meals"
    t.date     "deposit_date"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "token"
    t.string   "refresh_token"
    t.text     "credentials"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
