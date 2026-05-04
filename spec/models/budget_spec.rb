# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Budget, type: :model do
  subject { build(:budget) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:budget_month) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:account) }
  end

  describe 'normalizing budget_month' do
    it 'stores the first day of the month' do
      budget = build(:budget, budget_month: Date.new(2025, 3, 18))
      budget.validate
      expect(budget.budget_month).to eq(Date.new(2025, 3, 1))
    end
  end

  describe '#spent_transactions' do
    it 'returns debits to the budget category in that month, newest first' do
      user = create(:user)
      exp = user.accounts.create!(name: 'Exp', account_type: 'expense', initial_balance: 0)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      t1 = create(
        :transaction,
        user:,
        debit_account: exp,
        credit_account: bank,
        amount: 10,
        transaction_date: Date.new(2025, 4, 2)
      )
      t2 = create(
        :transaction,
        user:,
        debit_account: exp,
        credit_account: bank,
        amount: 20,
        transaction_date: Date.new(2025, 4, 15)
      )
      create(
        :transaction,
        user:,
        debit_account: exp,
        credit_account: bank,
        amount: 99,
        transaction_date: Date.new(2025, 3, 1)
      )

      budget = create(
        :budget,
        user:,
        account: exp,
        amount: 500,
        budget_month: Date.new(2025, 4, 1)
      )

      expect(budget.spent_transactions.to_a).to eq([t2, t1])
    end
  end

  describe '#spent_amount' do
    it 'sums amounts for debit transactions to the budget account in that calendar month' do
      user = create(:user)
      exp = user.accounts.create!(name: 'Exp', account_type: 'expense', initial_balance: 0)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      create(
        :transaction,
        user:,
        debit_account: exp,
        credit_account: bank,
        amount: 40,
        transaction_date: Date.new(2025, 2, 10)
      )
      create(
        :transaction,
        user:,
        debit_account: exp,
        credit_account: bank,
        amount: 5,
        transaction_date: Date.new(2025, 3, 5)
      )
      create(
        :transaction,
        user:,
        debit_account: bank,
        credit_account: exp,
        amount: 100,
        transaction_date: Date.new(2025, 3, 6)
      )

      budget = create(
        :budget,
        user:,
        account: exp,
        amount: 500,
        budget_month: Date.new(2025, 3, 1)
      )

      expect(budget.spent_amount).to eq(5)
    end

    it 'returns zero when there are no debits in the month' do
      user = create(:user)
      exp = user.accounts.create!(name: 'Exp', account_type: 'expense', initial_balance: 0)
      budget = create(
        :budget,
        user:,
        account: exp,
        amount: 100,
        budget_month: Date.new(2025, 1, 1)
      )
      expect(budget.spent_amount).to eq(0)
    end
  end
end
