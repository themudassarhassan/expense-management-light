# frozen_string_literal: true

module SystemSpecHelpers
  def sign_in_as(user, password: '1234345')
    visit new_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Sign in'
  end

  # Layout renders two sidebars, each with a Sign out <button>.
  def click_sign_out
    page.first(:button, 'Sign out').click
  end
end

RSpec.configure do |config|
  config.include SystemSpecHelpers, type: :system
end
