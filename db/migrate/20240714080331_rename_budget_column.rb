class RenameBudgetColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :budgets, :month, :budget_month
  end
end
