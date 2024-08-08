# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :type, null: false
      t.integer :amount, null: false
      t.string :description

      t.references :source_account, foreign_key: { to_table: :accounts }
      t.references :destination_account, foreign_key: { to_table: :accounts }

      t.references :user, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
