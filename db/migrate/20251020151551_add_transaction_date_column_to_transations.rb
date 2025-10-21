class AddTransactionDateColumnToTransations < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :transaction_date, :date
  end
end
