# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountBalanceCalculator do
  it 'raises when the account type is not supported' do
    account = instance_double(
      'Account',
      account_type: 'weird',
      initial_balance: 0,
      debit_transactions: double('Relation', sum: 0),
      credit_transactions: double('Relation', sum: 0)
    )
    expect { described_class.new(account).compute }
      .to raise_error(/Invalid account type/)
  end

  it 'treats person accounts like asset accounts (debit minus credit)' do
    user = create(:user)
    person = user.accounts.create!(name: 'P', account_type: 'person', initial_balance: 0)
    other = user.accounts.create!(name: 'B', account_type: 'bank', initial_balance: 0)
    create(
      :transaction,
      user:,
      debit_account: person,
      credit_account: other,
      amount: 10,
      transaction_date: Date.current
    )
    create(
      :transaction,
      user:,
      debit_account: other,
      credit_account: person,
      amount: 3,
      transaction_date: Date.current
    )
    expect(described_class.new(person.reload).compute).to eq(7)
  end

  it 'uses credit minus debit for income accounts' do
    user = create(:user)
    bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
    inc = user.accounts.create!(name: 'Salary', account_type: 'income', initial_balance: 0)
    create(
      :transaction,
      user:,
      debit_account: bank,
      credit_account: inc,
      amount: 5000,
      transaction_date: Date.current
    )
    expect(described_class.new(inc.reload).compute).to eq(5000)
  end

  it 'includes initial_balance for debit-normal accounts' do
    user = create(:user)
    bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 50)
    expect(described_class.new(bank.reload).compute).to eq(50)
  end

  it 'includes negative initial_balance for person accounts' do
    user = create(:user)
    person = user.accounts.create!(name: 'Friend', account_type: 'person', initial_balance: -25)
    expect(described_class.new(person.reload).compute).to eq(-25)
  end

  it 'combines negative initial_balance with transactions on person' do
    user = create(:user)
    person = user.accounts.create!(name: 'Friend', account_type: 'person', initial_balance: -100)
    other = user.accounts.create!(name: 'B', account_type: 'bank', initial_balance: 0)
    create(
      :transaction,
      user:,
      debit_account: person,
      credit_account: other,
      amount: 30,
      transaction_date: Date.current
    )
    expect(described_class.new(person.reload).compute).to eq(-70)
  end
end
