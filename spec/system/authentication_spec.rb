# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :system do
  describe 'registration' do
    it 'lets a new user register and land on the dashboard' do
      visit new_registrations_path
      fill_in 'Name', with: 'Flow User'
      email = "flow+#{SecureRandom.hex(3)}@example.com"
      fill_in 'Email', with: email
      fill_in 'Password', with: 'password12'
      click_button 'Create account'

      expect(page).to have_current_path(root_path, ignore_query: true)
      expect(page).to have_content('Dashboard')
    end
  end

  describe 'sign in' do
    it 'lets an existing user sign in' do
      user = create(:user, password: 'secret12', password_confirmation: 'secret12')

      sign_in_as(user, password: 'secret12')

      expect(page).to have_current_path(root_path, ignore_query: true)
      expect(page).to have_content('Dashboard')
    end
  end

  describe 'sign out' do
    it 'ends the session and shows sign in' do
      user = create(:user)
      sign_in_as(user)
      expect(page).to have_content('Dashboard')

      click_sign_out

      expect(page).to have_current_path(new_session_path, ignore_query: true)
      expect(page).to have_content('Sign in')
    end
  end
end
