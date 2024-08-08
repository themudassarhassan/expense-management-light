# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: %i[edit update destroy]

  def index
    @accounts = current_user.accounts
  end

  def new
    @account = Account.new
  end

  def edit; end

  def create
    @account = current_user.accounts.build(account_params)

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

    head :ok
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :balance, :account_type)
  end
end
