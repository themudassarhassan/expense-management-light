# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Budgets', type: :request do
  let(:user) { create(:user) }
  let(:expense_account) { user.accounts.create!(name: 'Category', account_type: 'expense', initial_balance: 0) }
  let(:month) { Date.current.beginning_of_month }

  it_behaves_like 'a request that requires sign-in' do
    let(:unauthenticated_request) { proc { get budgets_path } }
  end

  context 'when signed in' do
    before { sign_in_as(user) }

    describe 'GET /budgets' do
      it 'returns success' do
        get budgets_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Budgets')
      end
    end

    describe 'GET /budgets/new' do
      it_behaves_like 'a successful GET for a new form' do
        let(:new_path) { new_budget_path }
      end
    end

    describe 'POST /budgets' do
      it 'creates a budget' do
        expect do
          post budgets_path, params: {
            budget: { amount: 150, budget_month: month, account_id: expense_account.id }
          }
        end.to change { user.reload.budgets.count }.by(1)
        expect(response).to redirect_to(budgets_path)
      end
    end

    describe 'GET /budgets/:id/edit' do
      it 'returns success' do
        budget = user.budgets.create!(amount: 100, budget_month: month, account: expense_account)
        get edit_budget_path(budget)
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'a request to edit a missing record' do
        let(:missing_record_edit_path) { edit_budget_path(IMPOSSIBLE_RECORD_ID) }
      end
    end

    describe 'PATCH /budgets/:id' do
      it 'updates the budget' do
        budget = user.budgets.create!(amount: 100, budget_month: month, account: expense_account)
        patch budget_path(budget), params: {
          budget: { amount: 200, budget_month: month, account_id: expense_account.id }
        }
        expect(response).to redirect_to(budgets_path)
        expect(budget.reload.amount).to eq(200)
      end
    end

    describe 'DELETE /budgets/:id' do
      it 'destroys the budget' do
        budget = user.budgets.create!(amount: 50, budget_month: month, account: expense_account)
        expect { delete budget_path(budget) }.to change { Budget.count }.by(-1)
        expect(response).to redirect_to(budgets_path)
      end
    end
  end
end
