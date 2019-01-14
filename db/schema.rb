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

ActiveRecord::Schema.define(version: 20190110074149) do

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                     default: ""
    t.string   "last_name",                      default: ""
    t.string   "roles",                          default: "case worker"
    t.date     "start_date"
    t.string   "job_title",                      default: ""
    t.string   "mobile",                         default: ""
    t.date     "date_of_birth"
    t.boolean  "archived",                       default: false
    t.integer  "province_id"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                          default: "",            null: false
    t.string   "encrypted_password",             default: "",            null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                  default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "clients_count",                  default: 0
    t.integer  "cases_count",                    default: 0
    t.integer  "tasks_count",                    default: 0
    t.string   "provider",                       default: "email",       null: false
    t.string   "uid",                            default: "",            null: false
    t.json     "tokens"
    t.boolean  "admin",                          default: false
    t.integer  "changelogs_count",               default: 0
    t.integer  "organization_id"
    t.boolean  "disable",                        default: false
    t.datetime "expires_at"
    t.boolean  "task_notify",                    default: true
    t.integer  "manager_id"
    t.boolean  "calendar_integration",           default: false
    t.integer  "pin_number"
    t.integer  "manager_ids",                    default: [],                         array: true
    t.boolean  "program_warning",                default: false
    t.boolean  "staff_performance_notification", default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["organization_id"], name: "index_users_on_organization_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
