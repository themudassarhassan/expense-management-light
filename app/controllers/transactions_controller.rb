class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:edit, :update, :destroy]
  before_action :load_categories, only: [:new, :create, :update, :edit]
  before_action :load_user_accounts, only: [:new, :create, :update, :edit]
  
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
  
  def create
    @transaction = CreateTransaction.new(
      user: current_user,
      amount: transaction_params[:amount],
      type: transaction_params[:type],
      source_account_id: transaction_params[:source_account_id],
      destination_account_id: transaction_params[:destination_account_id],
      category_id: transaction_params[:category_id],
      description: transaction_params[:description]
    ).call

    if @transaction.persisted?
      redirect_to transactions_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @transaction = UpdateTransaction.new(
      transaction: @transaction,
      amount: transaction_params[:amount],
      type: transaction_params[:type],
      source_account_id: transaction_params[:source_account_id],
      destination_account_id: transaction_params[:destination_account_id],
      category_id: transaction_params[:category_id],
      description: transaction_params[:description]
    ).call
    
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
    )
  end
end
