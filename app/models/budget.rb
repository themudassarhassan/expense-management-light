# frozen_string_literal: true

class Budget < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :budget_month, presence: true

  belongs_to :user
  belongs_to :account

  def spent_amount
    user
      .transactions
      .within(budget_month.beginning_of_month, budget_month.end_of_month)
      .where(debit_account: account)
      .sum(:amount)
  end
end
