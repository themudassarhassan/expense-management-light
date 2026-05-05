# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts', type: :system do
  it 'lets a signed-in user create an account and see it listed' do
    user = create(:user)
    sign_in_as(user)

    visit new_account_path
    fill_in 'Name', with: 'Side Cash'
    choose 'Cash'
    fill_in 'Initial balance', with: '42.5'
    click_button 'Create Account'

    expect(page).to have_current_path(accounts_path, ignore_query: true)
    expect(page).to have_content('Side Cash')
    expect(page).to have_content('Cash')
    expect(page).to have_content('42.5')
  end

  it 'disables initial balance on edit after the account has transactions' do
    user = create(:user)
    bank = user.accounts.create!(name: 'Checking', account_type: 'bank', initial_balance: 100)
    cash = user.accounts.create!(name: 'Wallet', account_type: 'cash', initial_balance: 0)
    create(:transaction, user:, debit_account: bank, credit_account: cash, amount: 10)

    sign_in_as(user)
    visit edit_account_path(bank)

    expect(page).to have_field('Initial balance', disabled: true)
    expect(page).to have_content('cannot be changed after this account has transactions')
  end
end
