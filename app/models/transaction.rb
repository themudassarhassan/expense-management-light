class Transaction < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :type, presence: true
 
  belongs_to :user
  
  # TODO: any other way to do this?
  scope :within, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  def account_name
    return "#{source_account.name} > #{destination_account.name}" if type == 'Transactions::Transfer'
    
    account.name
  end
end
