# frozen_string_literal: true

module Transactions
  class Expense < Transaction
    belongs_to :category

    alias_attribute :account, :source_account

    scope :by_budget, ->(budget) { where(category: budget.category) }
  end
end
