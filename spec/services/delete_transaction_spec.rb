# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteTransaction do
  subject(:delete_transaction) do
    described_class.new(transaction:).call
  end

  let!(:user) { create(:user) }

  describe '#call' do
    context 'when deleting expense transaction' do
      let!(:source_account) { create(:account, user:, balance: 2000) }
      let!(:transaction) do
        create(:transaction, :expense, source_account:, user:, amount: 1000)
      end

      specify do
        delete_transaction

        expect(source_account.reload).to have_attributes(balance: 2000)

        expect(Transaction.count).to be_zero
      end
    end

    context 'when deleting income transaction' do
      let!(:destination_account) { create(:account, user:, balance: 2000) }
      let!(:transaction) do
        create(:transaction, :income, destination_account:, user:, amount: 1000)
      end

      specify do
        delete_transaction

        expect(destination_account.reload).to have_attributes(balance: 2000)

        expect(Transaction.count).to be_zero
      end
    end

    context 'when deleting transfer transaction' do
      let!(:destination_account) { create(:account, user:, balance: 2000) }
      let!(:source_account) { create(:account, user:, balance: 4000) }
      let!(:transaction) do
        create(:transaction, :transfer, destination_account:, source_account:, user:, amount: 1000)
      end

      specify do
        delete_transaction

        expect(destination_account.reload).to have_attributes(balance: 2000)
        expect(source_account.reload).to have_attributes(balance: 4000)

        expect(Transaction.count).to be_zero
      end
    end
  end
end
