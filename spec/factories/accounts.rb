# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }
    account_type { 'bank' }
    initial_balance { 20 }
    user

    trait :system_expense do
      system_generated { true }
      user { nil }
      account_type { 'expense' }
      initial_balance { 0 }
    end

    trait :system_income do
      system_generated { true }
      user { nil }
      account_type { 'income' }
      initial_balance { 0 }
    end
  end
end
