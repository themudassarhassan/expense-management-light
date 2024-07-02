module Transactions
  class Income < Transaction
    belongs_to :category
  end
end
