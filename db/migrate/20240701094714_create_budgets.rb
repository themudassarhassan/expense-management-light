# frozen_string_literal: true

class CreateBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :budgets do |t|
      t.integer :amount, null: false
      t.date :month, null: false

      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
