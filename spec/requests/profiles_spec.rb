# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user) }

  it_behaves_like 'a request that requires sign-in' do
    let(:unauthenticated_request) { proc { get edit_profile_path } }
  end

  context 'when signed in' do
    before { sign_in_as(user) }

    describe 'GET /profile/edit' do
      it 'returns success' do
        get edit_profile_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Your profile')
        expect(response.body).to include(user.email)
        expect(response.body).to include('Base currency')
      end
    end

    describe 'PATCH /profile' do
      it 'updates base currency' do
        patch profile_path, params: { user: { name: user.name, base_currency: 'USD' } }
        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.base_currency).to eq('USD')
      end

      it 'updates the name when password fields are omitted' do
        patch profile_path, params: { user: { name: 'Updated Name' } }
        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.name).to eq('Updated Name')
        expect(user.authenticate('1234345')).to eq(user)
      end

      it 'updates the password when current password is correct and confirmation matches' do
        new_password = 'password1password1'
        patch profile_path, params: {
          user: {
            name: user.name,
            current_password: '1234345',
            password: new_password,
            password_confirmation: new_password
          }
        }
        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.authenticate(new_password)).to eq(user)
      end

      it 're-renders when changing password without the current password' do
        patch profile_path, params: {
          user: {
            name: user.name,
            password: 'password1password1',
            password_confirmation: 'password1password1'
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Current password')
        expect(user.reload.authenticate('1234345')).to eq(user)
      end

      it 're-renders when the current password is wrong' do
        patch profile_path, params: {
          user: {
            name: user.name,
            current_password: 'wrong-password',
            password: 'password1password1',
            password_confirmation: 'password1password1'
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('incorrect')
        expect(user.reload.authenticate('1234345')).to eq(user)
      end

      it 're-renders when password confirmation does not match' do
        patch profile_path, params: {
          user: {
            name: user.name,
            current_password: '1234345',
            password: 'password1password1',
            password_confirmation: 'different'
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.reload.authenticate('1234345')).to eq(user)
      end

      it 'does not change email when an email param is posted' do
        original_email = user.email
        patch profile_path, params: {
          user: {
            name: user.name,
            email: 'attacker@example.com',
            password: '',
            password_confirmation: ''
          }
        }
        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.email).to eq(original_email)
      end
    end
  end
end
