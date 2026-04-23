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
