module Transactions
  class Income < Transaction
    belongs_to :category
    belongs_to :destination_account, class_name: 'Account', foreign_key: :destination_account_id
    
    alias_attribute :account, :destination_account
  end
end
