# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions', type: :system do
  it 'lets a signed-in user record an expense and see it on the list' do
    user = create(:user)
    user.accounts.create!(name: 'Checking', account_type: 'bank', initial_balance: 0)
    user.accounts.create!(name: 'Groceries', account_type: 'expense', initial_balance: 0)
    sign_in_as(user)

    visit new_transaction_path
    fill_in 'Amount', with: '18.25'
    select 'Checking', from: 'From account'
    select 'Groceries', from: 'Category'
    fill_in 'Date', with: Date.current.iso8601
    fill_in 'Description', with: 'E2E lunch'

    click_button 'Create Transaction'

    expect(page).to have_current_path(transactions_path, ignore_query: true)
    # Index table shows from → to accounts and amount (not the description in the row).
    expect(page).to have_content('Checking')
    expect(page).to have_content('Groceries')
    expect(page).to have_content('18.25')
  end
end
