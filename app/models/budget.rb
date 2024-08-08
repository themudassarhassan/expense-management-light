# frozen_string_literal: true

class Budget < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :budget_month, presence: true

  belongs_to :user
  belongs_to :category

  def spent_amount
    user
      .expense_transactions
      .within(budget_month.beginning_of_month, budget_month.end_of_month)
      .where(category_id: category.id)
      .sum(:amount)
  end
end
