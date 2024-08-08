# frozen_string_literal: true

class ListTransactions
  attr_reader :page, :per_page, :user_id, :category_id, :source_account_id, :destination_account_id

  # rubocop:disable Metrics/ParameterLists
  def initialize(user_id:, page: 1, per_page: 50, category_id: nil, source_account_id: nil, destination_account_id: nil)
    @page = page
    @per_page = per_page
    @user_id = user_id
    @category_id = category_id
    @source_account_id = source_account_id
    @destination_account_id = destination_account_id
  end
  # rubocop:enable Metrics/ParameterLists

  def call
    Transaction.where(search_params).offset(page_offset).limit(per_page).order(created_at: :desc)
  end

  private

  def search_params
    {
      user_id:,
      category_id:,
      source_account_id:,
      destination_account_id:
    }.compact
  end

  def page_offset
    (page - 1) * per_page
  end
end
