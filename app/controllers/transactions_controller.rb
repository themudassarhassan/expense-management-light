# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: %i[edit update destroy]
  before_action :load_categories, :load_user_accounts, only: %i[new create update edit]

  def index
    @transactions = ListTransactions.new(
      user_id: current_user.id,
      page: params.fetch(:page, 1),
      category_id: params[:category_id]
    ).call
  end

  def new
    @transaction = Transaction.new
  end

  def edit; end

  def create
    @transaction = CreateTransaction.new(user_id: current_user.id, **transaction_params).call

    if @transaction.persisted?
      redirect_to transactions_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @transaction = UpdateTransaction.new(transaction: @transaction, **transaction_params).call

    if @transaction.valid?
      redirect_to transactions_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    DeleteTransaction.new(transaction: @transaction).call
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def load_categories
    @categories = Category.all
  end

  def load_user_accounts
    @accounts = current_user.accounts
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount, :description, :source_account_id, :destination_account_id, :type, :category_id
    ).to_h.deep_symbolize_keys
  end
end
