# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    it_behaves_like 'a request that requires sign-in' do
      let(:unauthenticated_request) { proc { get root_path } }
    end

    it 'shows the dashboard when signed in' do
      user = create(:user)
      sign_in_as(user)

      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Dashboard')
    end
  end
end
