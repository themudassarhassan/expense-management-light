module Transactions
  class Expense < Transaction
    belongs_to :category
    belongs_to :source_account, class_name: 'Account', foreign_key: :source_account_id
  
    alias_attribute :account, :source_account
    
    scope :by_budget, ->(budget) { where(category: budget.category) }
  end
end
