class Budget < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :budget, presence: true

  belongs_to :user
  belongs_to :category
end
