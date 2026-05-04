# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions', type: :request do
  let(:user) { create(:user) }
  let(:bank) { user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0) }
  let(:expense) { user.accounts.create!(name: 'Food', account_type: 'expense', initial_balance: 0) }
  let(:income) { user.accounts.create!(name: 'Salary', account_type: 'income', initial_balance: 0) }

  it_behaves_like 'a request that requires sign-in' do
    let(:unauthenticated_request) { proc { get transactions_path } }
  end

  context 'when signed in' do
    before { sign_in_as(user) }

    describe 'GET /transactions' do
      it 'returns the HTML index' do
        get transactions_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Transactions')
      end

      it 'applies a simple type filter (HTML)' do
        a = user.accounts.create!(name: 'B2', account_type: 'bank', initial_balance: 0)
        create(
          :transaction,
          user:,
          debit_account: a,
          credit_account: bank,
          transaction_type: 'income',
          amount: 5,
          transaction_date: Date.current
        )
        get transactions_path, params: { type: 'income' }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/html')
      end

      it 'returns only transactions for the selected account' do
        bank1 = user.accounts.create!(name: 'Primary', account_type: 'bank', initial_balance: 0)
        bank2 = user.accounts.create!(name: 'Secondary', account_type: 'bank', initial_balance: 0)
        exp = user.accounts.create!(name: 'Cat', account_type: 'expense', initial_balance: 0)
        create(:transaction, user:, credit_account: bank1, debit_account: exp, amount: 101, transaction_date: Date.current)
        create(:transaction, user:, credit_account: bank2, debit_account: exp, amount: 102, transaction_date: Date.current)
        get transactions_path, params: { account_id: bank1.id }
        expect(response).to have_http_status(:ok)
        doc = Nokogiri::HTML(response.body)
        expect(doc.css('#transactions_tbody tr').size).to eq(1)
        expect(response.body).to include('101')
        expect(response.body).not_to include('102')
      end

      it 'includes table header links to toggle sort' do
        create(
          :transaction,
          user:,
          debit_account: expense,
          credit_account: bank,
          transaction_type: 'expense',
          amount: 3,
          transaction_date: Date.current
        )
        get transactions_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(/sort=date_asc/)
        expect(response.body).to match(/sort=amount_desc/)
      end

      it 'accepts a sort parameter' do
        create(
          :transaction,
          user:,
          debit_account: expense,
          credit_account: bank,
          transaction_type: 'expense',
          amount: 3,
          transaction_date: Date.current
        )
        get transactions_path, params: { sort: 'amount_asc' }
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET /transactions/new' do
      it_behaves_like 'a successful GET for a new form' do
        let(:new_path) { new_transaction_path }
      end
    end

    describe 'POST /transactions' do
      it 'creates a transaction' do
        expect do
          post transactions_path, params: {
            transaction: {
              amount: 15,
              transaction_type: 'expense',
              transaction_date: Date.current,
              description: 'Lunch',
              credit_account_id: bank.id,
              debit_account_id: expense.id
            }
          }
        end.to change { user.reload.transactions.count }.by(1)
        expect(response).to redirect_to(transactions_path)
      end
    end

    describe 'GET /transactions/:id/edit' do
      it 'returns success' do
        t = create(
          :transaction,
          user:,
          debit_account: expense,
          credit_account: bank,
          amount: 3,
          transaction_date: Date.current
        )
        get edit_transaction_path(t)
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'a request to edit a missing record' do
        let(:missing_record_edit_path) { edit_transaction_path(IMPOSSIBLE_RECORD_ID) }
      end
    end

    describe 'PATCH /transactions/:id' do
      it 'updates a transaction' do
        t = create(
          :transaction,
          user:,
          debit_account: expense,
          credit_account: bank,
          amount: 3,
          transaction_date: Date.current
        )
        patch transaction_path(t), params: {
          transaction: {
            amount: 9.5,
            description: 'Updated',
            credit_account_id: bank.id,
            debit_account_id: expense.id,
            transaction_date: Date.current
          }
        }
        expect(response).to redirect_to(transactions_path)
        expect(t.reload.amount).to eq(9.5)
      end
    end

    describe 'DELETE /transactions/:id' do
      it 'destroys the transaction' do
        t = create(
          :transaction,
          user:,
          debit_account: income,
          credit_account: bank,
          amount: 1000,
          transaction_type: 'income',
          transaction_date: Date.current
        )
        expect { delete transaction_path(t) }.to change { Transaction.count }.by(-1)
        expect(response).to redirect_to(transactions_path)
      end
    end
  end
end
