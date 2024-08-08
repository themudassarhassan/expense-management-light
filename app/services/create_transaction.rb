# frozen_string_literal: true

class CreateTransaction
  class UnknownTransactionTypeError < StandardError; end

  attr_reader :user, :amount, :type, :source_account_id, :destination_account_id, :category_id, :description

  # rubocop:disable Metrics/ParameterLists
  def initialize(user:, amount:, type:, source_account_id: nil, destination_account_id: nil, category_id: nil,
                 description: nil)
    @user = user
    @amount = amount.to_i
    @type = type
    @source_account_id = source_account_id
    @destination_account_id = destination_account_id
    @category_id = category_id
    @description = description
  end
  # rubocop:enable Metrics/ParameterLists

  def call
    ActiveRecord::Base.transaction do
      source_account&.update!(balance: source_account.balance - amount)
      destination_account&.update!(balance: destination_account.balance + amount)
      Transaction.create(transaction_params)
    end
  end

  private

  def transaction_class
    transactions_classes = {
      'transfer' => Transactions::Transfer,
      'income' => Transactions::Income,
      'expense' => Transactions::Expense
    }

    raise UnknownTransactionTypeError if transactions_classes[type].nil?

    transactions_classes[type]
  end

  def transaction_params
    { user:, amount:, source_account_id:, destination_account_id:, description:, category_id:, type: }.compact
  end

  def source_account
    @source_account ||= Account.find_by(id: source_account_id)
  end

  def destination_account
    @destination_account ||= Account.find_by(id: destination_account_id)
  end
end
