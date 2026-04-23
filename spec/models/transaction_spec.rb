# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  subject { build(:transaction) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_inclusion_of(:transaction_type).in_array(Transaction::TYPES) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:credit_account).class_name('Account') }
    it { is_expected.to belong_to(:debit_account).class_name('Account') }
  end

  describe 'after_initialize' do
    it 'sets transaction_type to expense when blank' do
      user = create(:user)
      debit = create(:account, user:)
      credit = create(:account, user:)
      t = described_class.create!(
        user:,
        debit_account: debit,
        credit_account: credit,
        amount: 1,
        transaction_date: Date.current,
        transaction_type: nil
      )
      expect(t.transaction_type).to eq('expense')
    end
  end

  describe '.within' do
    it 'returns only transactions in the inclusive date range' do
      user = create(:user)
      a = create(:account, user:)
      b = create(:account, user:)
      in_range = create(
        :transaction,
        user:,
        debit_account: a,
        credit_account: b,
        transaction_date: Date.new(2025, 1, 15)
      )
      create(
        :transaction,
        user:,
        debit_account: b,
        credit_account: a,
        transaction_date: Date.new(2024, 12, 31)
      )

      result = described_class.within(Date.new(2025, 1, 1), Date.new(2025, 1, 31))
      expect(result).to include(in_range)
    end
  end
end
