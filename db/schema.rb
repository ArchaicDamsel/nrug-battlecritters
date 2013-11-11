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

ActiveRecord::Schema.define(version: 20131110224751) do

  create_table "messages", force: true do |t|
    t.boolean  "outgoing"
    t.string   "path"
    t.text     "inspected_data"
    t.integer  "server_id"
    t.integer  "in_response_to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["in_response_to_id"], name: "index_messages_on_in_response_to_id"
  add_index "messages", ["server_id"], name: "index_messages_on_server_id"

  create_table "servers", force: true do |t|
    t.string   "hostname"
    t.string   "current_role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
