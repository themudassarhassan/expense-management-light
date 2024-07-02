class Account < ApplicationRecord
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :account_type, presence: true

  belongs_to :user
  
  enum account_type: %w[cash person bank].index_by(&:itself)
end
