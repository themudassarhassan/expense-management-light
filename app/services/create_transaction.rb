# frozen_string_literal: true

class CreateTransaction
  attr_reader :user_id, :amount, :transaction_type, :debit_account_id, :credit_account_id, :description,
              :transaction_date

  def initialize(**params)
    @user_id = params[:user_id]
    @amount = params[:amount]&.to_i
    @transaction_type = params[:transaction_type]
    @debit_account_id = params[:debit_account_id]
    @credit_account_id = params[:credit_account_id]
    @description = params[:description]
    @transaction_date = params[:transaction_date]
  end

  def call
    Transaction.create!(transaction_params)
  end

  private

  def transaction_params
    { user_id:, amount:, debit_account_id:, credit_account_id:, description:, transaction_type:,
      transaction_date: }.compact
  end
end
