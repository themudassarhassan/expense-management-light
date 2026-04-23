# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end

  describe 'secure password' do
    it { is_expected.to have_secure_password }
  end

  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:accounts).dependent(:destroy) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:budgets).dependent(:destroy) }
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:asset_accounts).to(:accounts) }
    it { is_expected.to delegate_method(:person_accounts).to(:accounts) }
  end

  describe '#expense_accounts' do
    it "returns the user's own expense accounts plus system expense accounts" do
      user = create(:user)
      own = user.accounts.create!(name: 'My expense', account_type: 'expense', initial_balance: 0)
      system = Account.create!(
        name: 'System expense',
        account_type: 'expense',
        system_generated: true,
        initial_balance: 0
      )

      expect(user.expense_accounts).to include(own, system)
    end
  end

  describe '#income_accounts' do
    it "returns the user's own income accounts plus system income accounts" do
      user = create(:user)
      own = user.accounts.create!(name: 'My income', account_type: 'income', initial_balance: 0)
      system = Account.create!(
        name: 'System income',
        account_type: 'income',
        system_generated: true,
        initial_balance: 0
      )

      expect(user.income_accounts).to include(own, system)
    end
  end

  describe '#to_accounts' do
    it 'for transfer, returns asset and person accounts' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      person = user.accounts.create!(name: 'Person', account_type: 'person', initial_balance: 0)

      expect(user.to_accounts(:transfer)).to include(bank, person)
    end

    it 'for non-transfer, returns only asset accounts' do
      user = create(:user)
      user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      person = user.accounts.create!(name: 'Person', account_type: 'person', initial_balance: 0)

      result = user.to_accounts(:income)
      expect(result).not_to include(person)
      expect(result).to match_array(user.asset_accounts)
    end
  end

  describe '#from_accounts' do
    it 'for transfer, returns asset and person accounts' do
      user = create(:user)
      bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      person = user.accounts.create!(name: 'Person', account_type: 'person', initial_balance: 0)

      expect(user.from_accounts(:transfer)).to include(bank, person)
    end

    it 'for non-transfer, returns only asset accounts' do
      user = create(:user)
      user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
      person = user.accounts.create!(name: 'Person', account_type: 'person', initial_balance: 0)

      result = user.from_accounts(:expense)
      expect(result).not_to include(person)
      expect(result).to match_array(user.asset_accounts)
    end
  end
end
