module Transactions
  class Expense < Transaction
    belongs_to :category
    belongs_to :source_account, class_name: 'Account', foreign_key: :source_account_id
  end
end
