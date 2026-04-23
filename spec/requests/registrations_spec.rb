# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'GET /registrations/new' do
    it 'returns success' do
      get new_registrations_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /registrations' do
    it 'creates a user and signs them in' do
      email = "reg-#{SecureRandom.hex(4)}@example.com"
      expect do
        post registrations_path, params: {
          user: { name: 'Pat Lee', email:, password: 'password1' * 2 }
        }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it 're-renders with an error status when invalid' do
      post registrations_path, params: {
        user: { name: '', email: 'bad', password: 'short' }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
