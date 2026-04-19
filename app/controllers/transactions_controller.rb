# frozen_string_literal: true

class TransactionsController < ApplicationController
  helper DashboardHelper

  before_action :set_transaction, only: %i[edit update destroy]

  def index
    @transactions = ListTransactions.new(
      user_id: Current.user.id,
      page: params.fetch(:page, 1),
      category_id: params[:category_id]
    ).call
  end

  def new
    @transaction = Transaction.new(params.permit(:transaction_type))
    @from_dashboard = params[:dashboard_context].present?
  end

  def edit; end

  def create
    @transaction = Transaction.new(transaction_params.merge(user: Current.user))

    if @transaction.save
      if params[:dashboard_context].present?
        respond_to do |format|
          format.html { redirect_to root_path, notice: "Transaction saved." }
          format.turbo_stream do
            @dashboard = Dashboard::Snapshot.new(Current.user)
            render :create
          end
        end
      else
        redirect_to transactions_path, notice: "Transaction saved."
      end
    else
      @from_dashboard = params[:dashboard_context].present?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy

    redirect_to transactions_path
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount, :description, :debit_account_id, :credit_account_id, :transaction_type, :transaction_date
    )
  end
end
