# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  subject { build(:account) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:currency_code).in_array(CurrencyOptions::CODES) }

    context 'when account type is cash or bank (asset)' do
      subject { build(:account, account_type: 'bank') }

      it { is_expected.to validate_numericality_of(:initial_balance).is_greater_than_or_equal_to(0) }
    end

    context 'when account type is person' do
      it 'allows negative initial_balance' do
        account = build(:account, account_type: 'person', initial_balance: -50, user: create(:user))
        expect(account).to be_valid
      end

      it 'still requires initial_balance to be numeric' do
        account = build(:account, account_type: 'person', initial_balance: 'not-a-number', user: create(:user))
        expect(account).not_to be_valid
      end
    end

    it 'rejects negative initial_balance for a bank account' do
      account = build(:account, account_type: 'bank', initial_balance: -1)
      expect(account).not_to be_valid
    end

    it 'does not allow changing initial_balance after transactions exist' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 10)
      other = user.accounts.create!(name: 'Cash', account_type: 'cash', initial_balance: 0)
      create(:transaction, user:, debit_account: bank, credit_account: other, amount: 5)

      bank.initial_balance = 99
      expect(bank).not_to be_valid
      expect(bank.errors[:initial_balance]).to include('cannot be changed after transactions exist')
    end

    it 'allows changing initial_balance when there are no transactions yet' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 10)

      bank.initial_balance = 20
      expect(bank).to be_valid
    end

    it 'allows updating name while initial_balance unchanged after transactions exist' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 10)
      other = user.accounts.create!(name: 'Cash', account_type: 'cash', initial_balance: 0)
      create(:transaction, user:, debit_account: bank, credit_account: other, amount: 5)

      bank.name = 'Renamed'
      expect(bank).to be_valid
    end

    it 'rejects a non-enum account_type' do
      # String enum blocks invalid values (before inclusion runs); use assert_raises-style expectation.
      expect { build(:account, account_type: 'not_a_type') }
        .to raise_error(ArgumentError, /not a valid account_type/i)
    end

    context 'when the account is not system-generated' do
      it 'requires a user' do
        account = build(:account, user: nil, system_generated: false)
        expect(account).not_to be_valid
        expect(account.errors[:user_id]).to include("can't be blank")
      end
    end

    context 'when the account is system-generated' do
      it 'is valid without a user' do
        expect(build(:account, :system_expense)).to be_valid
        expect(build(:account, :system_income)).to be_valid
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }

    it {
      is_expected.to have_many(:credit_transactions)
        .class_name('Transaction')
        .with_foreign_key(:credit_account_id)
        .dependent(:destroy)
        .inverse_of(:credit_account)
    }

    it {
      is_expected.to have_many(:debit_transactions)
        .class_name('Transaction')
        .with_foreign_key(:debit_account_id)
        .dependent(:destroy)
        .inverse_of(:debit_account)
    }
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    describe '.asset_accounts' do
      it 'returns only cash and bank accounts' do
        bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
        cash = user.accounts.create!(name: 'Cash', account_type: 'cash', initial_balance: 0)
        person = user.accounts.create!(name: 'Person', account_type: 'person', initial_balance: 0)

        expect(Account.asset_accounts).to include(bank, cash)
        expect(Account.asset_accounts).not_to include(person)
      end
    end

    describe '.person_accounts' do
      it 'returns only person accounts' do
        person = user.accounts.create!(name: 'Person', account_type: 'person', initial_balance: 0)
        bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)

        expect(Account.person_accounts).to include(person)
        expect(Account.person_accounts).not_to include(bank)
      end
    end

    describe '.system_expense_accounts' do
      it 'returns system-generated expense accounts' do
        system = create(:account, :system_expense)
        own = user.accounts.create!(name: 'Own exp', account_type: 'expense', initial_balance: 0)

        expect(Account.system_expense_accounts).to include(system)
        expect(Account.system_expense_accounts).not_to include(own)
      end
    end

    describe '.system_income_accounts' do
      it 'returns system-generated income accounts' do
        system = create(:account, :system_income)
        own = user.accounts.create!(name: 'Own inc', account_type: 'income', initial_balance: 0)

        expect(Account.system_income_accounts).to include(system)
        expect(Account.system_income_accounts).not_to include(own)
      end
    end
  end

  describe '#current_balance' do
    it 'for an asset account, is debit debits minus credit debits' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      other = user.accounts.create!(name: 'Other', account_type: 'cash', initial_balance: 0)
      create(
        :transaction,
        user: user,
        debit_account: bank,
        credit_account: other,
        amount: 100
      )
      create(
        :transaction,
        user: user,
        debit_account: other,
        credit_account: bank,
        amount: 30
      )

      expect(bank.reload.current_balance).to eq(70)
    end

    it 'includes initial_balance for an asset account' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 100)
      other = user.accounts.create!(name: 'Other', account_type: 'cash', initial_balance: 0)
      create(
        :transaction,
        user: user,
        debit_account: bank,
        credit_account: other,
        amount: 100
      )
      create(
        :transaction,
        user: user,
        debit_account: other,
        credit_account: bank,
        amount: 30
      )

      expect(bank.reload.current_balance).to eq(170)
    end

    it 'includes negative initial_balance for a person account' do
      user = create(:user)
      person = user.accounts.create!(name: 'Alice', account_type: 'person', initial_balance: -40)

      expect(person.reload.current_balance).to eq(-40)
    end

    it 'for an expense account, is credit total minus debit total' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      expense = user.accounts.create!(name: 'Groceries', account_type: 'expense', initial_balance: 0)
      create(
        :transaction,
        user: user,
        debit_account: bank,
        credit_account: expense,
        amount: 25
      )

      expect(expense.reload.current_balance).to eq(25)
    end

    it 'includes initial_balance for an expense account' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      expense = user.accounts.create!(name: 'Groceries', account_type: 'expense', initial_balance: 10)
      create(
        :transaction,
        user: user,
        debit_account: bank,
        credit_account: expense,
        amount: 25
      )

      expect(expense.reload.current_balance).to eq(35)
    end
  end

  describe '#transactions' do
    it 'returns transactions where the account is credit or debit' do
      user = create(:user)
      a = user.accounts.create!(name: 'A', account_type: 'bank', initial_balance: 0)
      b = user.accounts.create!(name: 'B', account_type: 'cash', initial_balance: 0)
      c = user.accounts.create!(name: 'C', account_type: 'person', initial_balance: 0)

      as_debit = create(
        :transaction,
        user: user,
        debit_account: a,
        credit_account: b,
        amount: 10
      )
      as_credit = create(
        :transaction,
        user: user,
        debit_account: c,
        credit_account: a,
        amount: 5
      )
      unrelated = create(
        :transaction,
        user: user,
        debit_account: b,
        credit_account: c,
        amount: 1
      )

      expect(a.reload.transactions).to contain_exactly(as_debit, as_credit)
      expect(a.transactions).not_to include(unrelated)
    end
  end
end
