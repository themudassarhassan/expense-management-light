class Transaction < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :type, presence: true
 
  belongs_to :user
end
