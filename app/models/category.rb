# frozen_string_literal: true

class Category < ApplicationRecord
  validates :name, :category_type, presence: true

  enum category_type: %w[expense income].index_by(&:itself)
end
