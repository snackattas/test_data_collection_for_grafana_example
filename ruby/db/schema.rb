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

ActiveRecord::Schema[7.1].define(version: 2024_01_03_021328) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "test_cases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "test_execution", null: false
    t.string "status", null: false
    t.integer "parallel_process", null: false
    t.string "name", null: false
    t.string "path", null: false
    t.string "exception_class"
    t.string "exception_message"
    t.string "exception_traceback"
    t.string "pending_message"
    t.json "data", default: {}
    t.datetime "finished_at", precision: nil
    t.index ["test_execution"], name: "index_test_cases_on_test_execution"
  end

  create_table "test_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "test_groups", default: [], array: true
    t.string "build_id"
    t.string "branch"
    t.string "url"
    t.string "commit_author"
    t.string "git_hash"
    t.integer "parallel_processes", default: 1, null: false
    t.boolean "cd", default: false, null: false
    t.boolean "rerun", default: false, null: false
    t.string "status"
    t.boolean "error"
    t.datetime "finished_at", precision: nil
    t.index ["build_id", "rerun"], name: "index_test_executions_on_build_id_and_rerun", unique: true
  end

end
