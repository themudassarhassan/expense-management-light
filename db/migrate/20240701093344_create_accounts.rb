# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.decimal :initial_balance, null: false, default: 0, scale: 2, precision: 12
      t.boolean :system_generated, null: false, default: false
      t.string :account_type, null: false
      t.timestamps
    end
  end
end
