class Transaction < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :type, presence: true
 
  belongs_to :user
  
  def account_name
    return "#{source_account.name} > #{destination_account.name}" if type == 'Transactions::Transfer'
    
    account.name
  end
end
