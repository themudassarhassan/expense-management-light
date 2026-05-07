# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  attr_accessor :current_password

  validates :name, :email, presence: true
  validates :email, uniqueness: true
  validates :base_currency, inclusion: { in: CurrencyOptions::CODES }

  has_many :sessions, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy

  delegate :asset_accounts, :person_accounts, to: :accounts

  def expense_accounts
    own_expense_accounts + Account.system_expense_accounts
  end

  def income_accounts
    own_income_accounts + Account.system_income_accounts
  end

  def to_accounts(transaction_type)
    transaction_type == :transfer ? asset_accounts + person_accounts : asset_accounts
  end

  def from_accounts(transaction_type)
    transaction_type == :transfer ? asset_accounts + person_accounts : asset_accounts
  end

  private

  def own_expense_accounts
    accounts.where(account_type: Account::EXPENSE_TYPE)
  end

  def own_income_accounts
    accounts.where(account_type: Account::INCOME_TYPE)
  end
end
