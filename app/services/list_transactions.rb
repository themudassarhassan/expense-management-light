class ListTransactions
  
  attr_reader :page, :per_page, :user_id, :category_id

  def initialize(page: 1, per_page: 50, user_id:, category_id: nil)
    @page = page
    @per_page = per_page
    @user_id = user_id
    @category_id = category_id
  end
  
  def call
    Transaction.where(search_params).offset(page_offset).limit(per_page).order(created_at: :desc)
  end
  
  private
  
  def search_params
    {
      user_id:,
      category_id:
    }.compact
  end
  
  def page_offset
    (page - 1) * per_page
  end
end
