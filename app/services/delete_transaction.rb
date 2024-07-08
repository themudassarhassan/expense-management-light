class DeleteTransaction
  attr_reader :transaction
  
  def initialize(transaction:)
    @transaction = transaction
  end
  
  def call
    ActiveRecord::Base.transaction do
      source_account&.update(balance: source_account.balance + transaction.amount)
      destination_account&.update(balance: destination_account.balance - transaction.amount)
      transaction.destroy
    end
  end
  
  private
  
  def source_account
    @source_account ||= Account.find_by(id: transaction.source_account_id)
  end
  
  def destination_account
    destination_account ||= Account.find_by(id: transaction.destination_account_id)
  end
end
