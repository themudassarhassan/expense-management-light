class AddIndexTransactionsOnUserIdAndTransactionDate < ActiveRecord::Migration[7.1]
  def change
    add_index :transactions, %i[user_id transaction_date],
              name: 'index_transactions_on_user_id_and_transaction_date'
  end
end
