# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /session/new' do
    it 'returns success' do
      get new_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Sign in')
    end
  end

  describe 'POST /session' do
    it 'signs the user in and redirects to the root' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')

      post session_path, params: { email: user.email, password: 'secret123' }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Dashboard')
    end

    it 'redirects back to sign-in when credentials are wrong' do
      user = create(:user, password: 'right', password_confirmation: 'right')
      post session_path, params: { email: user.email, password: 'wrong' }
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'DELETE /session' do
    it 'signs the user out and redirects to sign-in' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')
      sign_in_as(user, password: 'secret123')

      delete session_path

      expect(response).to redirect_to(new_session_path)

      get root_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
