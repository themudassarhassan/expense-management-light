# frozen_string_literal: true

class BudgetsController < ApplicationController
  before_action :set_budget, only: %i[edit update destroy]
  before_action :load_expense_accounts, only: %i[new create edit update]

  def index
    @budgets = Current.user.budgets.order(budget_month: :desc)
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

    head :ok
  end

  private

  def load_expense_accounts
    @expense_accounts = Current.user.expense_accounts
  end

  def set_budget
    @budget = Budget.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:amount, :budget_month, :account_id)
  end
end
