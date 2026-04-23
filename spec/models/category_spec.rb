# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  subject { build(:category) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:category_type) }

    it 'rejects a non-enum category_type' do
      expect { build(:category, category_type: 'other') }
        .to raise_error(ArgumentError, /not a valid category_type/i)
    end
  end
end
