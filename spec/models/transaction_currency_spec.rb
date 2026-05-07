# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, 'currency pairing' do
  let(:user) { create(:user) }

  it 'allows an expense against a shared system category regardless of seeded category currency' do
    bank = create(:account, user:, account_type: 'bank', currency_code: 'PKR')
    system_cat = create(:account, :system_expense)

    txn = described_class.new(
      user:,
      credit_account: bank,
      debit_account: system_cat,
      amount: 5,
      transaction_date: Time.zone.today,
      transaction_type: 'expense'
    )

    expect(txn).to be_valid
  end

  it 'allows bank and owned category sharing the same currency' do
    bank = create(:account, user:, account_type: 'bank', currency_code: 'EUR')
    cat = create(:account, user:, account_type: 'expense', currency_code: 'EUR')

    txn = described_class.new(
      user:,
      credit_account: bank,
      debit_account: cat,
      amount: 5,
      transaction_date: Time.zone.today,
      transaction_type: 'expense'
    )

    expect(txn).to be_valid
  end

  it 'rejects owned category in a different currency than the bank' do
    bank = create(:account, user:, account_type: 'bank', currency_code: 'PKR')
    cat = create(:account, user:, account_type: 'expense', currency_code: 'EUR')

    txn = described_class.new(
      user:,
      credit_account: bank,
      debit_account: cat,
      amount: 5,
      transaction_date: Time.zone.today,
      transaction_type: 'expense'
    )

    expect(txn).not_to be_valid
    expect(txn.errors[:base]).to include('debit and credit accounts must share the same currency')
  end

  it 'rejects transfers between two user accounts with different currencies' do
    a = create(:account, user:, account_type: 'bank', currency_code: 'PKR')
    b = create(:account, user:, account_type: 'cash', currency_code: 'USD')

    txn = described_class.new(
      user:,
      credit_account: a,
      debit_account: b,
      amount: 10,
      transaction_date: Time.zone.today,
      transaction_type: 'transfer'
    )

    expect(txn).not_to be_valid
  end

  it 'rejects transactions that only touch system accounts' do
    a = create(:account, :system_expense)
    b = create(:account, :system_income)

    txn = described_class.new(
      user:,
      credit_account: a,
      debit_account: b,
      amount: 10,
      transaction_date: Time.zone.today,
      transaction_type: 'expense'
    )

    expect(txn).not_to be_valid
  end
end
