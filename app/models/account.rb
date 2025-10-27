# frozen_string_literal: true

class Account < ApplicationRecord
  ASSET_TYPES = %w[cash bank].freeze
  EXPENSE_TYPE = 'expense'
  INCOME_TYPE = 'income'
  PERSON_TYPE = 'person'

  TYPES = ASSET_TYPES + [EXPENSE_TYPE, INCOME_TYPE, PERSON_TYPE]

  validates :initial_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true
  validates :account_type, inclusion: { in: TYPES }
  validates :user_id, presence: true, unless: :system_generated

  belongs_to :user, optional: true

  enum account_type: TYPES.index_by(&:itself)

  scope :asset_accounts, -> { where(account_type: ASSET_TYPES) }
  scope :system_expense_accounts, -> { where(account_type: EXPENSE_TYPE, system_generated: true) }
  scope :system_income_accounts, -> { where(account_type: INCOME_TYPE, system_generated: true) }

  def transactions
    Transaction.where('credit_account_id = ? or debit_account_id = ?', id, id)
  end
end
