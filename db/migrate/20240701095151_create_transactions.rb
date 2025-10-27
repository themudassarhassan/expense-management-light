# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :transaction_type, null: false
      t.decimal :amount, null: false, scale: 2, precision: 12
      t.string :description

      t.references :debit_account, foreign_key: { to_table: :accounts }
      t.references :credit_account, foreign_key: { to_table: :accounts }

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
