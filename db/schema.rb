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

ActiveRecord::Schema[7.1].define(version: 2026_01_23_120000) do
  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "initial_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "system_generated", default: false, null: false
    t.string "account_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.date "budget_month", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id", null: false
    t.index ["account_id"], name: "index_budgets_on_account_id"
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_type", default: "expense", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "transaction_type", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "description"
    t.integer "debit_account_id", null: false
    t.integer "credit_account_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "transaction_date", null: false
    t.index ["credit_account_id"], name: "index_transactions_on_credit_account_id"
    t.index ["debit_account_id"], name: "index_transactions_on_debit_account_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "budgets", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "transactions", "accounts", column: "credit_account_id"
  add_foreign_key "transactions", "accounts", column: "debit_account_id"
  add_foreign_key "transactions", "users"
end
