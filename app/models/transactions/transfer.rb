module Transactions
  class Transfer < Transaction
    belongs_to :destination_account, class_name: 'Account', foreign_key: :destination_account_id
  end
end
