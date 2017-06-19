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

ActiveRecord::Schema.define(version: 20170619074853) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.integer  "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "device_id"
    t.index ["user_id"], name: "index_devices_on_user_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "tournament_id"
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.date     "start_date"
    t.index ["tournament_id"], name: "index_groups_on_tournament_id", using: :btree
  end

  create_table "groups_teams", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "team_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "order"
    t.integer  "points",           default: 0
    t.integer  "score_difference", default: 0
    t.integer  "wins",             default: 0
    t.integer  "draws",            default: 0
    t.integer  "losses",           default: 0
    t.index ["group_id"], name: "index_groups_teams_on_group_id", using: :btree
    t.index ["team_id"], name: "index_groups_teams_on_team_id", using: :btree
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "status"
    t.integer  "match_id"
    t.datetime "time"
    t.integer  "invitee_id"
    t.integer  "inviter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "venue_id"
    t.index ["match_id"], name: "index_invitations_on_match_id", using: :btree
  end

  create_table "matches", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "venue_id"
    t.integer  "team_a_id"
    t.integer  "team_b_id"
    t.datetime "time"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "code"
    t.integer  "score_a",           default: 0
    t.integer  "score_b",           default: 0
    t.integer  "point_a",           default: 0
    t.integer  "point_b",           default: 0
    t.text     "calendar_link"
    t.text     "note"
    t.integer  "invitations_count", default: 0
    t.index ["group_id"], name: "index_matches_on_group_id", using: :btree
    t.index ["team_a_id"], name: "index_matches_on_team_a_id", using: :btree
    t.index ["team_b_id"], name: "index_matches_on_team_b_id", using: :btree
    t.index ["venue_id"], name: "index_matches_on_venue_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.integer  "tournament_id"
    t.string   "name"
    t.string   "locale"
    t.text     "html_content"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["tournament_id"], name: "index_pages_on_tournament_id", using: :btree
  end

  create_table "players", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "team_id"
    t.index ["team_id"], name: "index_players_on_team_id", using: :btree
    t.index ["tournament_id"], name: "index_players_on_tournament_id", using: :btree
    t.index ["user_id"], name: "index_players_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_roles_users_on_role_id", using: :btree
    t.index ["user_id"], name: "index_roles_users_on_user_id", using: :btree
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "tournament_id"
    t.integer  "status"
    t.integer  "venue_ranking", default: [],              array: true
    t.index ["tournament_id"], name: "index_teams_on_tournament_id", using: :btree
  end

  create_table "time_slots", force: :cascade do |t|
    t.datetime "time"
    t.boolean  "available"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "match_id"
  end

  create_table "tournament_translations", force: :cascade do |t|
    t.integer  "tournament_id",        null: false
    t.string   "locale",               null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "competition_mode"
    t.text     "competition_fee"
    t.text     "competition_schedule"
    t.index ["locale"], name: "index_tournament_translations_on_locale", using: :btree
    t.index ["tournament_id"], name: "index_tournament_translations_on_tournament_id", using: :btree
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "start_date"
    t.date     "end_date"
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "phone_number"
    t.integer  "skill_level"
    t.text     "address"
    t.text     "note"
    t.string   "slug"
    t.string   "facebook_uid"
    t.json     "facebook_credentials"
    t.integer  "skill_id"
    t.date     "birthday"
    t.string   "club"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["slug"], name: "index_users_on_slug", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  end

  create_table "venues", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "google_calendar_name"
  end

  add_foreign_key "devices", "users"
  add_foreign_key "groups", "tournaments"
  add_foreign_key "invitations", "matches"
  add_foreign_key "invitations", "teams", column: "invitee_id"
  add_foreign_key "invitations", "teams", column: "inviter_id"
  add_foreign_key "invitations", "venues"
  add_foreign_key "players", "teams"
  add_foreign_key "players", "tournaments"
  add_foreign_key "players", "users"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
  add_foreign_key "teams", "tournaments"
  add_foreign_key "time_slots", "matches"
  add_foreign_key "users", "skills"
end
