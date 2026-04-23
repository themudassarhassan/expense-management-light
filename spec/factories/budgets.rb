# frozen_string_literal: true

FactoryBot.define do
  factory :budget do
    amount { 100 }
    budget_month { Date.current.beginning_of_month }
    user
    account { association :account, user: }
  end
end
