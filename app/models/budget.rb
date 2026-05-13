# frozen_string_literal: true

class Budget < ApplicationRecord
  before_validation :normalize_budget_month

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :budget_month, presence: true

  validate :account_must_be_permitted_expense_category

  belongs_to :user
  belongs_to :account

  def spent_transactions
    user
      .transactions
      .within(budget_month.beginning_of_month, budget_month.end_of_month)
      .where(debit_account: account)
      .order(transaction_date: :desc, id: :desc)
  end

  def spent_amount
    spent_transactions.sum(:amount)
  end

  private

  def account_must_be_permitted_expense_category
    return if account.blank?

    unless account.expense?
      errors.add(:account, :invalid)
      return
    end

    permitted = account.system_generated? || account.user_id == user_id
    errors.add(:account, :invalid) unless permitted
  end

  def normalize_budget_month
    self.budget_month = budget_month.beginning_of_month if budget_month.present?
  end
end
