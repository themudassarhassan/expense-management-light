class AddExpenseAccountToBudget < ActiveRecord::Migration[7.1]
  def change
    add_reference :budgets, :account, null: false # rubocop:disable Rails/NotNullColumn
  end
end
