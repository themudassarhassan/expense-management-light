# frozen_string_literal: true

class BudgetsController < ApplicationController
  helper DashboardHelper

  before_action :set_budget, only: %i[show edit update destroy]
  before_action :load_expense_accounts, only: %i[new create edit update]

  def index
    @budgets = Current.user.budgets.includes(:account).order(budget_month: :desc)
  end

  def show
    scope = @budget.spent_transactions.includes(:credit_account, :debit_account)
    @pagy, @transactions = pagy(:offset, scope)
    if budget_show_page_overflow?
      redirect_to budget_path(@budget, page: @pagy.last)
      return
    end
  end

  def new
    @budget = Budget.new
  end

  def edit; end

  def create
    @budget = Current.user.budgets.new(budget_params)
    if @budget.save
      redirect_to budgets_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to budgets_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @budget.destroy

    redirect_to budgets_path
  end

  private

  def load_expense_accounts
    @expense_accounts = Current.user.expense_accounts
  end

  def set_budget
    @budget = Current.user.budgets.includes(:account).find(params[:id])
  end

  def budget_show_page_overflow?
    @pagy.last && (@pagy.page > @pagy.last)
  end

  def budget_params
    params.require(:budget).permit(:amount, :budget_month, :account_id)
  end
end
