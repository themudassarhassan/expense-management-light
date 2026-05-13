# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  let(:user) { create(:user) }

  it_behaves_like 'a request that requires sign-in' do
    let(:unauthenticated_request) { proc { get accounts_path } }
  end

  context 'when signed in' do
    before { sign_in_as(user) }

    describe 'GET /accounts' do
      it 'returns success' do
        get accounts_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Accounts')
      end
    end

    describe 'GET /accounts/new' do
      it_behaves_like 'a successful GET for a new form' do
        let(:new_path) { new_account_path }
      end
    end

    describe 'POST /accounts' do
      it 'creates an account and redirects' do
        expect do
          post accounts_path, params: {
            account: { name: 'Cash jar', account_type: 'cash', initial_balance: 12.5 }
          }
        end.to change { user.reload.accounts.count }.by(1)
        expect(response).to redirect_to(accounts_path)
      end
    end

    describe 'GET /accounts/:id/edit' do
      it 'returns success for the user’s account' do
        account = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 0)
        get edit_account_path(account)
        expect(response).to have_http_status(:ok)
      end

      it 'does not load another user account' do
        other_account = create(:user).accounts.create!(name: 'Other', account_type: 'bank', initial_balance: 0)
        get edit_account_path(other_account)
        expect(response).to redirect_to(root_path)
      end

      it_behaves_like 'a request to edit a missing record' do
        let(:missing_record_edit_path) { edit_account_path(IMPOSSIBLE_RECORD_ID) }
      end
    end

    describe 'PATCH /accounts/:id' do
      it 'updates the account' do
        account = user.accounts.create!(name: 'Old', account_type: 'bank', initial_balance: 0)
        patch account_path(account), params: {
          account: { name: 'New name', account_type: 'bank', initial_balance: 0 }
        }
        expect(response).to redirect_to(accounts_path)
        expect(account.reload.name).to eq('New name')
      end

      it 'does not update another user account' do
        other_account = create(:user).accounts.create!(name: 'Victim', account_type: 'bank', initial_balance: 0)
        patch account_path(other_account), params: {
          account: { name: 'Hacked', account_type: 'bank', initial_balance: 0 }
        }
        expect(response).to redirect_to(root_path)
        expect(other_account.reload.name).to eq('Victim')
      end

      it 'rejects changing initial_balance after transactions exist' do
        bank = user.accounts.create!(name: 'Bank', account_type: 'bank', initial_balance: 10)
        other = user.accounts.create!(name: 'Cash', account_type: 'cash', initial_balance: 0)
        create(:transaction, user:, debit_account: bank, credit_account: other, amount: 5)

        patch account_path(bank), params: {
          account: { name: 'Bank', account_type: 'bank', initial_balance: 999 }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(bank.reload.initial_balance).to eq(10)
      end
    end

    describe 'DELETE /accounts/:id' do
      it 'destroys the account' do
        account = user.accounts.create!(name: 'Temp', account_type: 'bank', initial_balance: 0)
        expect do
          delete account_path(account)
        end.to change { Account.count }.by(-1)
        expect(response).to redirect_to(accounts_path)
      end

      it 'does not destroy another user account' do
        other_account = create(:user).accounts.create!(name: 'Keep', account_type: 'bank', initial_balance: 0)
        expect do
          delete account_path(other_account)
        end.not_to change { Account.count }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
