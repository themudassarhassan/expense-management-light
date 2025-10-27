# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

expense_accounts = %w[Food Mobile Fuel Home Travel]
income_accounts = %w[Salary Investment Rent]

expense_accounts.each do |account_name|
  Account.create!(name: account_name, account_type: :expense, system_generated: true)
end

income_accounts.each do |account_name|
  Account.create!(name: account_name, account_type: :income, system_generated: true)
end
