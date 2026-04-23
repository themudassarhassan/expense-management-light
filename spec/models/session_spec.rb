# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'optional attributes' do
    it 'persists ip_address and user_agent when set' do
      session = create(
        :session,
        ip_address: '198.51.100.1',
        user_agent: 'Mozilla/5.0 (test)'
      )
      expect(session.reload.ip_address).to eq('198.51.100.1')
      expect(session.reload.user_agent).to eq('Mozilla/5.0 (test)')
    end
  end
end
