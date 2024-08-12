# frozen_string_literal: true

class CreateTransaction
  attr_reader :user_id, :amount, :type, :source_account_id, :destination_account_id, :category_id, :description

  def initialize(**params)
    @user_id = params[:user_id]
    @amount = params[:amount]&.to_i
    @type = params[:type]
    @source_account_id = params[:source_account_id]
    @destination_account_id = params[:destination_account_id]
    @category_id = params[:category_id]
    @description = params[:description]
  end

  def call
    ActiveRecord::Base.transaction do
      transaction = Transaction.create!(transaction_params)
      source_account&.update!(balance: source_account.balance - amount)
      destination_account&.update!(balance: destination_account.balance + amount)
      transaction
    end
  end

  private

  def transaction_params
    { user_id:, amount:, source_account_id:, destination_account_id:, description:, category_id:, type: }.compact
  end

  def source_account
    @source_account ||= Account.find_by(id: source_account_id)
  end

  def destination_account
    @destination_account ||= Account.find_by(id: destination_account_id)
  end
end
