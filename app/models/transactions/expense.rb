module Transactions
  class Expense < Transaction
    belongs_to :category
  end
end
