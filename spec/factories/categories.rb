# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    category_type { 'expense' }

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
