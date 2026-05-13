# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :set_account, only: %i[edit update destroy]

  def index
    @accounts = Current.user.accounts
  end

  def new
    @account = Account.new
    @account.currency_code ||= Current.user.base_currency
  end

  def edit; end

  def create
    @account = Current.user.accounts.build(account_params)

    if @account.save
      redirect_to accounts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy

    redirect_to accounts_path
  end

  private

  def set_account
    @account = Current.user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :initial_balance, :account_type, :currency_code)
  end
end
