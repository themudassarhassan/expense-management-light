# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    amount { 100 }
    description { 'Some text' }
    user

    trait :income do
      type { 'Transactions::Income' }

      after(:build) do |transaction|
        transaction.destination_account.update(balance: transaction.destination_account.balance + transaction.amount)
      end
    end

    trait :expense do
      type { 'Transactions::Expense' }

      after(:build) do |transaction|
        transaction.source_account.update(balance: transaction.source_account.balance - transaction.amount)
      end
    end

    trait :transfer do
      type { 'Transactions::Transfer' }

      after(:build) do |transaction|
        transaction.destination_account.update(balance: transaction.destination_account.balance + transaction.amount)
        transaction.source_account.update(balance: transaction.source_account.balance - transaction.amount)
      end
    end
  end
end
