class Transaction < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  belongs_to :user
  
  belongs_to :source_account, class_name: 'Account', foreign_key: :source_account_id
end
