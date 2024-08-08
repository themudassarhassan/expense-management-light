# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.1]
  def up
    create_enum :account_types, %w[cash person bank]

    create_table :accounts do |t|
      t.string :name
      t.integer :balance, null: false, default: 0
      t.enum :account_type, enum_type: :account_types, null: false
      t.timestamps
    end
  end

  def down
    drop_table :accounts

    execute <<-SQL.squish
      DROP TYPE account_types;
    SQL
  end
end
