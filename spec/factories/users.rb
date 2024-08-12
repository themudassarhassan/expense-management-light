# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Alex Frank' }
    email { 'alex@gmail.com' }
    password { '1234345' }
  end
end
