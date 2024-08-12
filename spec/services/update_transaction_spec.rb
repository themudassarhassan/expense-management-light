# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateTransaction do
  subject(:update_transaction) do
    described_class.new(transaction:, **fields_to_update).call
  end
  
  let!(:user) { create(:user) }
  let!(:bank_account) { create(:account, user:, account_type: 'bank', balance: 2000) }
  let!(:cash_account) { create(:account, user:, account_type: 'cash', balance: 5000) }

  describe '#call' do
    context 'when amount and description of transaction' do
      let!(:transaction) do
        create(:transaction, :expense, source_account: bank_account, user:, amount: 1000)
      end
      let(:fields_to_update) do
        { amount: 2000, description: 'Amount changed.'}
      end
      
      specify do
        update_transaction
        
        expect(transaction.reload).to have_attributes(amount: 2000, description: 'Amount changed.')
        expect(bank_account.reload).to have_attributes(balance: 0)
      end
    end
    
    context 'when updating source account of expense transaction' do
      let!(:transaction) do
        create(:transaction, :expense, source_account: bank_account, user:, amount: 1000)
      end
      let(:fields_to_update) do
        { source_account_id: cash_account.id }
      end
      
      specify do
        update_transaction
        
        expect(transaction.reload).to have_attributes(amount: 1000, source_account_id: cash_account.id)
        expect(cash_account.reload).to have_attributes(balance: 4000)
        expect(bank_account.reload).to have_attributes(balance: 2000)
      end
    end
    
    context 'when updating destination account of income transaction' do
      let!(:transaction) do
        create(:transaction, :income, destination_account: bank_account, user:, amount: 1000)
      end
      let(:fields_to_update) do
        { destination_account_id: cash_account.id }
      end
      
      specify do
        update_transaction
        
        expect(transaction.reload).to have_attributes(amount: 1000, destination_account_id: cash_account.id)
        expect(cash_account.reload).to have_attributes(balance: 6000)
        expect(bank_account.reload).to have_attributes(balance: 2000)
      end
    end
    
    context 'when updating amount of transfer transaction' do
      let!(:transaction) do
        create(:transaction, :transfer, destination_account: bank_account, source_account: cash_account, user:, amount: 1000)
      end
      let(:fields_to_update) do
        { amount: 2000 }
      end
      
      specify do
        update_transaction
        
        expect(transaction.reload).to have_attributes(amount: 2000)
        expect(cash_account.reload).to have_attributes(balance: 3000)
        expect(bank_account.reload).to have_attributes(balance: 4000)
      end
    end
  end
end
