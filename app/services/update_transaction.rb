class UpdateTransaction
  attr_reader :transaction, :fields_to_update

  def initialize(transaction:, **fields_to_update)
    @transaction = transaction
    @fields_to_update = fields_to_update || {}
  end
  
  def call
    ActiveRecord::Base.transaction do
      revert_amount_of_previous_accounts
      transaction.update!(transaction_params)
      adjust_amount_of_current_accounts
      transaction
    end  
  end
  
  private
  
  def adjust_amount_of_current_accounts
    source_account&.update!(balance: source_account.balance - transaction.amount)
    destination_account&.update!(balance: destination_account.balance + transaction.amount)
  end
  
  def revert_amount_of_previous_accounts
    if ['Transactions::Expense', 'Transactions::Transfer'].include?(transaction.type)
      transaction.source_account.update!(balance: transaction.source_account.balance + transaction.amount)
    end
    
    if ['Transactions::Income', 'Transactions::Transfer'].include?(transaction.type)
      transaction.destination_account.update!(balance: transaction.destination_account.balance - transaction.amount)
    end
  end

  def source_account
    @source_account ||= Account.find_by(id: source_account_id)
  end
  
  def destination_account
    @destination_account ||= Account.find_by(id: destination_account_id)
  end

  def source_account_id
    fields_to_update[:source_account_id] || transaction.source_account_id
  end
  
  def destination_account_id
    fields_to_update[:destination_account_id] || transaction.destination_account_id
  end

  def transaction_params
    fields_to_update.compact
  end
end
