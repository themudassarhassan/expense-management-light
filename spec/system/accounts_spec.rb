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
    # Account type column (radio was "Cash"); index shows current balance from transactions, not initial balance alone.
    expect(page).to have_content('Cash')
  end
end
