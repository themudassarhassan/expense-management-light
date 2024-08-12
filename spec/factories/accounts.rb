# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    name { 'My bank account' }
    account_type { 'bank' }
    balance { 20 }
  end
end
