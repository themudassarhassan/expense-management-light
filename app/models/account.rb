# frozen_string_literal: true

class Account < ApplicationRecord
  TYPES = %w[cash person bank expense income].freeze

  validates :initial_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true
  validates :account_type, inclusion: { in: TYPES }
  validates :user_id, presence: true, unless: :system_generated

  belongs_to :user, optional: true

  enum account_type: TYPES.index_by(&:itself)
end
