# frozen_string_literal: true

class AccountBalanceCalculator
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def compute
    case account.account_type
    when *Account::ASSET_TYPES, Account::PERSON_TYPE
      calculate_debit_balance
    when Account::EXPENSE_TYPE, Account::INCOME_TYPE
      calculate_credit_balance
    else
      raise 'Invalid account type'
    end
  end

  private

  def calculate_debit_balance
    baseline = account.initial_balance.to_d
    baseline + account.debit_transactions.sum(:amount) - account.credit_transactions.sum(:amount)
  end

  def calculate_credit_balance
    baseline = account.initial_balance.to_d
    baseline + account.credit_transactions.sum(:amount) - account.debit_transactions.sum(:amount)
  end
end
