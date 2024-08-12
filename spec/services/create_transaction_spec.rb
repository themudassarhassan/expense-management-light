# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateTransaction do
  subject(:create_transaction) do
    described_class.new(**create_transaction_params).call
  end

  let(:create_transaction_params) do
    {
      amount:,
      type:,
      description:,
      user_id: user.id,
      source_account_id: source_account.id,
      destination_account_id: destination_account.id
    }.compact
  end
  let!(:user) { create(:user) }
  let!(:source_account) { create(:account, user:, balance: 1000) }
  let!(:destination_account) { create(:account, user:, balance: 500) }
  let(:amount) { 100 }
  let(:type) { 'Transactions::Transfer' }
  let(:description) { 'Transaction description' }

  describe '#call' do
    context 'when transaction type is transfer' do
      it 'updates source and destination account balances' do
        expect { create_transaction }.to change { source_account.reload.balance }.by(-amount)
                                                                                 .and change {
                                                                                        destination_account.reload.balance
                                                                                      }.by(amount)

        expect(create_transaction).to have_attributes(amount: 100, source_account_id: source_account.id,
                                                      destination_account_id: destination_account.id,
                                                      description: 'Transaction description',
                                                      user_id: user.id)
      end
    end

    context 'when transaction type is income' do
      let(:type) { 'Transactions::Income' }
      let!(:category) { create(:category, :income) }
      let(:create_transaction_params) do
        super().tap do |params|
          params[:category_id] = category.id
        end
      end

      it 'updates destination account balance' do
        expect { create_transaction }.to change { destination_account.reload.balance }.by(amount)

        expect(create_transaction).to have_attributes(amount: 100, destination_account_id: destination_account.id,
                                                      description: 'Transaction description', user_id: user.id,
                                                      category_id: category.id)
      end
    end

    context 'when transaction type is expense' do
      let(:type) { 'Transactions::Expense' }
      let!(:category) { create(:category, :expense) }
      let(:create_transaction_params) do
        super().tap do |params|
          params[:category_id] = category.id
        end
      end

      it 'updates source account balance' do
        expect { create_transaction }.to change { source_account.reload.balance }.by(-amount)

        expect(create_transaction).to have_attributes(amount: 100, source_account_id: source_account.id,
                                                      description: 'Transaction description', user_id: user.id,
                                                      category_id: category.id)
      end
    end

    context 'when transaction amount is negative' do
      let(:amount) { -100 }

      specify do
        expect { create_transaction }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when transaction user is not present' do
      let(:create_transaction_params) do
        super().tap do |params|
          params[:user_id] = nil
        end
      end

      specify do
        expect { create_transaction }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when transaction amount is not present' do
      let(:amount) { nil }

      specify do
        expect { create_transaction }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when transaction type is not present' do
      let(:type) { nil }

      specify do
        expect { create_transaction }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
