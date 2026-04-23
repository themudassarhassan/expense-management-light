# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Current, type: :model do
  after { described_class.reset }

  it 'exposes the assigned session' do
    session = build(:session)
    described_class.session = session
    expect(described_class.session).to be(session)
  end

  it 'delegates user to the current session' do
    user = build(:user)
    session = build(:session, user:)
    described_class.session = session
    expect(described_class.user).to be(user)
  end

  it 'returns a nil user when there is no session' do
    described_class.session = nil
    expect(described_class.user).to be_nil
  end
end
