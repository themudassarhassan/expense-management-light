# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsFilter do
  let(:user) { create(:user) }
  let(:params) { {} }
  let(:filter) { described_class.new(user:, params:) }

  describe '#date_range' do
    it 'defaults to this_month' do
      expect(filter.date_range).to eq('this_month')
    end

    it 'uses an allowed value when present' do
      params = { date_range: 'last_7_days' }
      f = described_class.new(user:, params:)
      expect(f.date_range).to eq('last_7_days')
    end

    it 'falls back to this_month for an unknown value' do
      params = { date_range: 'nope' }
      f = described_class.new(user:, params:)
      expect(f.date_range).to eq('this_month')
    end
  end

  describe '#type' do
    it 'is nil when missing or not allowed' do
      expect(filter.type).to be_nil
      f = described_class.new(user:, params: { type: 'borrow' })
      expect(f.type).to be_nil
    end

    it 'returns allowed type keys' do
      f = described_class.new(user:, params: { type: 'income' })
      expect(f.type).to eq('income')
    end
  end

  describe '#resettable?' do
    it 'is false with empty params' do
      expect(filter).not_to be_resettable
    end

    it 'is true when type is set' do
      f = described_class.new(user:, params: { type: 'expense' })
      expect(f).to be_resettable
    end

    it 'is true when custom date fields are set' do
      f = described_class.new(user:, params: { from_date: '2025-01-01' })
      expect(f).to be_resettable
    end

    it 'is true when date_range differs from this_month' do
      f = described_class.new(user:, params: { date_range: 'last_month' })
      expect(f).to be_resettable
    end

    it 'is true when page is after the first' do
      f = described_class.new(user:, params: { page: '2' })
      expect(f).to be_resettable
    end

    it 'is true when sort is not the default' do
      f = described_class.new(user:, params: { sort: 'date_asc' })
      expect(f).to be_resettable
    end

    it 'is true when a valid account filter is set' do
      bank = create(:account, user:, account_type: 'bank')
      f = described_class.new(user:, params: { account_id: bank.id.to_s })
      expect(f).to be_resettable
    end

    it 'is true when account_id param is invalid' do
      f = described_class.new(user:, params: { account_id: '999999' })
      expect(f).to be_resettable
    end
  end

  describe '#sort' do
    it 'defaults to date_desc' do
      expect(filter.sort).to eq('date_desc')
    end

    it 'returns allowed sort keys' do
      f = described_class.new(user:, params: { sort: 'amount_asc' })
      expect(f.sort).to eq('amount_asc')
    end
  end

  describe '#scope' do
    let(:a) { create(:account, user:) }
    let(:b) { create(:account, user:) }

    it 'only includes the given user’s transactions' do
      other = create(:user)
      oa = create(:account, user: other)
      ob = create(:account, user: other)
      create(:transaction, user: other, debit_account: oa, credit_account: ob, transaction_type: 'expense',
                           transaction_date: Date.current, amount: 1)
      mine = create(
        :transaction,
        user:,
        debit_account: a,
        credit_account: b,
        transaction_type: 'expense',
        transaction_date: Date.current,
        amount: 2
      )

      f = described_class.new(user:, params: {})
      expect(f.scope).to contain_exactly(mine)
    end

    it 'filters by type when set' do
      inc = create(
        :transaction,
        user:,
        debit_account: a,
        credit_account: b,
        transaction_type: 'income',
        transaction_date: Date.current,
        amount: 1
      )
      create(
        :transaction,
        user:,
        debit_account: b,
        credit_account: a,
        transaction_type: 'expense',
        transaction_date: Date.current,
        amount: 2
      )
      f = described_class.new(user:, params: { type: 'income' })
      expect(f.scope).to contain_exactly(inc)
    end

    it 'filters by account when the account is on either side of the flow' do
      bank1 = create(:account, user:, account_type: 'bank', name: 'One')
      bank2 = create(:account, user:, account_type: 'bank', name: 'Two')
      exp = create(:account, user:, account_type: 'expense', name: 'Cat')
      t_match = create(
        :transaction,
        user:,
        credit_account: bank1,
        debit_account: exp,
        transaction_type: 'expense',
        transaction_date: Date.current,
        amount: 7
      )
      create(
        :transaction,
        user:,
        credit_account: bank2,
        debit_account: exp,
        transaction_type: 'expense',
        transaction_date: Date.current,
        amount: 8
      )
      f = described_class.new(user:, params: { account_id: bank1.id.to_s })
      expect(f.scope).to contain_exactly(t_match)
    end

    it 'filters by category for expense and income legs' do
      bank = create(:account, user:, account_type: 'bank')
      exp = create(:account, user:, account_type: 'expense', name: 'Food')
      inc = create(:account, user:, account_type: 'income', name: 'Salary')
      t_exp = create(
        :transaction,
        user:,
        credit_account: bank,
        debit_account: exp,
        transaction_type: 'expense',
        transaction_date: Date.current,
        amount: 3
      )
      t_inc = create(
        :transaction,
        user:,
        credit_account: inc,
        debit_account: bank,
        transaction_type: 'income',
        transaction_date: Date.current,
        amount: 4
      )
      f1 = described_class.new(user:, params: { category_id: exp.id.to_s })
      expect(f1.scope).to contain_exactly(t_exp)
      f2 = described_class.new(user:, params: { category_id: inc.id.to_s })
      expect(f2.scope).to contain_exactly(t_inc)
    end

    it 'orders by transaction_date descending by default' do
      older = create(:account, user:)
      newer = create(:account, user:)
      t_old = create(
        :transaction,
        user:,
        debit_account: older,
        credit_account: newer,
        transaction_date: Date.new(2024, 1, 1),
        amount: 1
      )
      t_new = create(
        :transaction,
        user:,
        debit_account: newer,
        credit_account: older,
        transaction_date: Date.new(2024, 6, 1),
        amount: 2
      )
      f = described_class.new(user:, params: { date_range: 'custom', from_date: '2024-01-01', to_date: '2024-12-31' })
      expect(f.scope.to_a).to eq([t_new, t_old])
    end

    it 'orders by amount ascending when sort is amount_asc' do
      a = create(:account, user:)
      b = create(:account, user:)
      t_small = create(
        :transaction,
        user:,
        debit_account: a,
        credit_account: b,
        transaction_date: Date.current,
        amount: 5
      )
      t_large = create(
        :transaction,
        user:,
        debit_account: b,
        credit_account: a,
        transaction_date: Date.current,
        amount: 50
      )
      f = described_class.new(user:, params: { sort: 'amount_asc' })
      expect(f.scope.to_a).to eq([t_small, t_large])
    end

    it 'ignores account_id that does not belong to the user' do
      other = create(:user)
      their_bank = create(:account, user: other, account_type: 'bank')
      mine_a = create(:account, user:)
      mine_b = create(:account, user:)
      t = create(:transaction, user:, debit_account: mine_a, credit_account: mine_b, transaction_date: Date.current)
      f = described_class.new(user:, params: { account_id: their_bank.id.to_s })
      expect(f.scope).to contain_exactly(t)
    end
  end

  describe 'custom date range' do
    let(:a) { create(:account, user:) }
    let(:b) { create(:account, user:) }

    it 'sets an error and returns an empty scope when from is after to' do
      f = described_class.new(
        user:,
        params: { date_range: 'custom', from_date: '2025-01-10', to_date: '2025-01-01' }
      )
      expect(f.scope).to be_empty
      expect(f.date_range_error).to eq('Start date must be on or before end date.')
    end
  end
end
