# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles', type: :system do
  it 'lets a signed-in user open profile from the navbar and update their name' do
    user = create(:user, name: 'Nav User Original')
    sign_in_as(user)
    visit root_path

    first(:link, 'Nav User Original').click

    expect(page).to have_current_path(edit_profile_path, ignore_query: true)

    fill_in 'Name', with: 'Nav User Updated'
    click_button 'Save profile'

    expect(page).to have_current_path(edit_profile_path, ignore_query: true)
    expect(page).to have_content('Your profile has been updated')
    expect(user.reload.name).to eq('Nav User Updated')
  end
end
