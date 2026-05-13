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

    context 'when accounts are not owned by the user or system-generated' do
      it 'is invalid when the debit account belongs to someone else' do
        u1 = create(:user)
        u2 = create(:user)
        mine = create(:account, user: u1)
        foreign = create(:account, user: u2)
        tx = build(:transaction, user: u1, debit_account: foreign, credit_account: mine)
        expect(tx).not_to be_valid
        expect(tx.errors).to include(:debit_account)
      end

      it 'is invalid when the credit account belongs to someone else' do
        u1 = create(:user)
        u2 = create(:user)
        mine = create(:account, user: u1)
        foreign = create(:account, user: u2)
        tx = build(:transaction, user: u1, debit_account: mine, credit_account: foreign)
        expect(tx).not_to be_valid
        expect(tx.errors).to include(:credit_account)
      end

      it 'is valid when using a system-generated category account' do
        u = create(:user)
        bank = create(:account, user: u)
        system_cat = create(:account, :system_expense)
        tx = build(
          :transaction,
          user: u,
          debit_account: system_cat,
          credit_account: bank,
          transaction_type: 'expense'
        )
        expect(tx).to be_valid
      end
    end
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
