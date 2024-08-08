# frozen_string_literal: true

module Transactions
  class Income < Transaction
    belongs_to :category

    alias_attribute :account, :destination_account
  end
end
