# frozen_string_literal: true

class Transaction < ApplicationRecord
  TYPES = %w[income expense borrow lend transfer pay receive].freeze

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :transaction_type, inclusion: { in: TYPES }

  belongs_to :user
  belongs_to :credit_account, class_name: 'Account'
  belongs_to :debit_account, class_name: 'Account'

  validate :debit_and_credit_accounts_must_be_accessible_to_user
  validate :matching_account_currencies

  after_initialize :set_default, if: :new_record?

  scope :within, ->(start_date, end_date) { where(transaction_date: start_date..end_date) }

  def set_default
    self.transaction_type ||= 'expense'
  end

  private

  def debit_and_credit_accounts_must_be_accessible_to_user
    return if user.blank?

    errors.add(:debit_account, :invalid) if debit_account.present? && !account_accessible_to_user?(debit_account)
    errors.add(:credit_account, :invalid) if credit_account.present? && !account_accessible_to_user?(credit_account)
  end

  def account_accessible_to_user?(acc)
    acc.user_id == user.id || acc.system_generated?
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def matching_account_currencies
    debit_acc = debit_account
    credit_acc = credit_account
    return if debit_acc.blank? || credit_acc.blank?

    if debit_acc.system_generated? && credit_acc.system_generated?
      errors.add(:base, 'cannot transfer between system-generated categories')
      return
    end

    return if debit_acc.system_generated? || credit_acc.system_generated?

    return if debit_acc.currency_code == credit_acc.currency_code

    errors.add(:base, 'debit and credit accounts must share the same currency')
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
