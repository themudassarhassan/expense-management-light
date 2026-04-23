# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    amount { 100 }
    description { 'Some text' }
    transaction_type { 'expense' }
    transaction_date { Date.current }
    user
    debit_account { association :account, user: user }
    credit_account { association :account, user: user }
  end
end
