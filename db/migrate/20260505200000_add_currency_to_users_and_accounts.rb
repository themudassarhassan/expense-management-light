# frozen_string_literal: true

class AddCurrencyToUsersAndAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :base_currency, :string, null: false, default: 'PKR'

    add_column :accounts, :currency_code, :string, null: false, default: 'PKR'
  end
end
