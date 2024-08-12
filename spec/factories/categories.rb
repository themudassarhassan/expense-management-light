# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    trait :expense do
      name { 'Food' }
      category_type { 'expense' }
    end

    trait :income do
      name { 'Salary' }
      category_type { 'income' }
    end
  end
end
