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

ActiveRecord::Schema.define(version: 20160911154509) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "activity_feeds", force: :cascade do |t|
    t.integer  "actor_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "activity_feeds", ["actor_id"], name: "index_activity_feeds_on_actor_id", using: :btree
  add_index "activity_feeds", ["subject_type", "subject_id"], name: "index_activity_feeds_on_subject_type_and_subject_id", using: :btree

  create_table "applications", force: :cascade do |t|
    t.integer  "status",     default: 0
    t.integer  "user_id"
    t.integer  "integer_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "applications", ["integer_id"], name: "index_applications_on_integer_id", using: :btree
  add_index "applications", ["role_id"], name: "index_applications_on_role_id", using: :btree
  add_index "applications", ["user_id"], name: "index_applications_on_user_id", using: :btree

  create_table "bmarks", force: :cascade do |t|
    t.string   "title",                      null: false
    t.boolean  "complete",   default: false, null: false
    t.datetime "due_date"
    t.integer  "user_id"
    t.integer  "project_id",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "bmarks", ["project_id"], name: "index_bmarks_on_project_id", using: :btree
  add_index "bmarks", ["user_id"], name: "index_bmarks_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "color_hex"
    t.string   "icon_class"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "categories_tasks", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "task_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content",    null: false
    t.integer  "project_id", null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["project_id"], name: "index_comments_on_project_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "connections", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "status",        default: 0
    t.integer  "user_id"
    t.integer  "connection_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
  end

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "followable_id"
    t.string   "followable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "follows", ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id", using: :btree
  add_index "follows", ["user_id"], name: "index_follows_on_user_id", using: :btree

  create_table "interests", force: :cascade do |t|
    t.string   "title",      null: false
    t.integer  "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "interests", ["profile_id"], name: "index_interests_on_profile_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "profile_id", null: false
    t.string   "geo_string", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "body"
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "messages", ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifier_id",                   null: false
    t.string   "notifier_type",                 null: false
    t.integer  "action",        default: 0,     null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "actor_id",                      null: false
    t.integer  "notify_id",                     null: false
    t.boolean  "is_read",       default: false
  end

  create_table "notifiers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "positions", force: :cascade do |t|
    t.string   "title",      null: false
    t.string   "company"
    t.integer  "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "positions", ["profile_id"], name: "index_positions_on_profile_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "content"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "bmark_id"
  end

  add_index "posts", ["bmark_id"], name: "index_posts_on_bmark_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "owner",                                null: false
    t.integer  "creator",                              null: false
    t.integer  "status",                   default: 0
    t.integer  "conversation_id"
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string   "type"
    t.string   "sponsor"
    t.decimal  "payment_price"
  end

  add_index "projects", ["conversation_id"], name: "index_projects_on_conversation_id", using: :btree

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id"], name: "index_projects_users_on_project_id", using: :btree
  add_index "projects_users", ["user_id"], name: "index_projects_users_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "title",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "application_id"
    t.integer  "category_id"
  end

  add_index "roles", ["project_id"], name: "index_roles_on_project_id", using: :btree

  create_table "school_infos", force: :cascade do |t|
    t.integer  "profile_id",  null: false
    t.string   "school_name", null: false
    t.integer  "grad_year",   null: false
    t.string   "field"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "title",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "category_id"
  end

  add_index "skills", ["category_id"], name: "index_skills_on_category_id", using: :btree

  create_table "skills_tasks", id: false, force: :cascade do |t|
    t.integer "skill_id"
    t.integer "task_id"
  end

  create_table "skillsets", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "skillsets", ["user_id"], name: "index_skillsets_on_user_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "status",      default: 0
    t.integer  "project_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "bmark_id"
    t.integer  "user_id"
  end

  add_index "tasks", ["bmark_id"], name: "index_tasks_on_bmark_id", using: :btree
  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id", using: :btree
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "tasks_users", id: false, force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "user_id", null: false
  end

  add_index "tasks_users", ["task_id", "user_id"], name: "index_tasks_users_on_task_id_and_user_id", using: :btree
  add_index "tasks_users", ["user_id", "task_id"], name: "index_tasks_users_on_user_id_and_task_id", using: :btree

  create_table "user_conversations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.boolean  "is_read"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "user_conversations", ["conversation_id", "user_id"], name: "index_user_conversations_on_conversation_id_and_user_id", using: :btree
  add_index "user_conversations", ["conversation_id"], name: "index_user_conversations_on_conversation_id", using: :btree
  add_index "user_conversations", ["user_id"], name: "index_user_conversations_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "authentication_token"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "notification_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["notification_id"], name: "index_users_on_notification_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_projects", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
  end

  add_index "users_projects", ["project_id"], name: "index_users_projects_on_project_id", using: :btree
  add_index "users_projects", ["user_id"], name: "index_users_projects_on_user_id", using: :btree

  add_foreign_key "conversations", "projects"
  add_foreign_key "follows", "users"
  add_foreign_key "interests", "profiles"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "positions", "profiles"
  add_foreign_key "posts", "bmarks"
  add_foreign_key "projects", "conversations"
  add_foreign_key "skills", "categories"
  add_foreign_key "skillsets", "users"
  add_foreign_key "tasks", "bmarks"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users"
  add_foreign_key "user_conversations", "conversations"
  add_foreign_key "user_conversations", "users"
  add_foreign_key "users", "notifications"
end
