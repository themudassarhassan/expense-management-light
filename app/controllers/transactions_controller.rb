# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[edit update destroy]

  def index
    @transactions_filter = TransactionsFilter.new(user: Current.user, params: filter_params)
    @any_transactions = Transaction.where(user: Current.user).exists?
    scope = @transactions_filter.scope
    @pagy, @transactions = pagy(:offset, scope)
    redirect_to transactions_path(request.query_parameters.merge(page: @pagy.last)) if transactions_page_overflow?
    return if performed?

    # Turbo may follow redirects with an Accept that prefers turbo_stream. Our index
    # turbo_stream template only appends rows (load more); full visits must be HTML.
    coerce_transactions_index_to_html! unless transactions_index_load_more_stream?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @transaction = Transaction.new(params.permit(:transaction_type))
  end

  def edit; end

  def create
    @transaction = Transaction.new(transaction_params.merge(user: Current.user))

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy

    redirect_to transactions_path
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount, :description, :debit_account_id, :credit_account_id, :transaction_type, :transaction_date
    )
  end

  def filter_params
    params.permit(:date_range, :from_date, :to_date, :type, :page)
  end

  def transactions_page_overflow?
    @pagy.last && (@pagy.page > @pagy.last)
  end

  def transactions_index_load_more_stream?
    request.format == :turbo_stream && params[:page].to_i >= 2
  end

  def coerce_transactions_index_to_html!
    return unless request.format == :turbo_stream

    request.format = :html
  end
end
