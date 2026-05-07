# frozen_string_literal: true

class Account < ApplicationRecord
  ASSET_TYPES = %w[cash bank].freeze
  EXPENSE_TYPE = 'expense'
  INCOME_TYPE = 'income'
  PERSON_TYPE = 'person'

  TYPES = ASSET_TYPES + [EXPENSE_TYPE, INCOME_TYPE, PERSON_TYPE]

  validates :initial_balance, numericality: { greater_than_or_equal_to: 0 }, unless: :person?
  validates :initial_balance, numericality: true, if: :person?
  validates :name, presence: true
  validates :currency_code, inclusion: { in: CurrencyOptions::CODES }
  validates :account_type, inclusion: { in: TYPES }
  validates :user_id, presence: true, unless: :system_generated

  validate :initial_balance_immutable_when_transactions_exist, on: :update

  belongs_to :user, optional: true
  has_many :credit_transactions, class_name: 'Transaction', foreign_key: :credit_account_id, dependent: :destroy,
                                 inverse_of: :credit_account

  has_many :debit_transactions, class_name: 'Transaction', foreign_key: :debit_account_id, dependent: :destroy,
                                inverse_of: :debit_account

  enum account_type: TYPES.index_by(&:itself)

  scope :person_accounts, -> { where(account_type: PERSON_TYPE) }
  scope :asset_accounts, -> { where(account_type: ASSET_TYPES) }
  scope :system_expense_accounts, -> { where(account_type: EXPENSE_TYPE, system_generated: true) }
  scope :system_income_accounts, -> { where(account_type: INCOME_TYPE, system_generated: true) }

  def current_balance
    AccountBalanceCalculator.new(self).compute
  end

  def transactions
    Transaction.where('credit_account_id = ? or debit_account_id = ?', id, id)
  end

  private

  def initial_balance_immutable_when_transactions_exist
    return unless initial_balance_changed?
    return unless transactions.exists?

    errors.add(:initial_balance, 'cannot be changed after transactions exist')
  end
end
