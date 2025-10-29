# frozen_string_literal: true

class Transaction < ApplicationRecord
  TYPES = %w[income expense borrow lend transfer pay receive].freeze

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :transaction_type, inclusion: { in: TYPES }

  belongs_to :user

  belongs_to :credit_account, class_name: 'Account'
  belongs_to :debit_account, class_name: 'Account'

  after_initialize :set_default, if: :new_record?

  scope :within, ->(start_date, end_date) { where(transaction_date: start_date..end_date) }

  def set_default
    self.transaction_type ||= 'expense'
  end
end
