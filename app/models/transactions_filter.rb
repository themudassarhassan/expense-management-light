# frozen_string_literal: true

class TransactionsFilter
  DATE_RANGE_KEYS = %w[last_7_days this_month last_month custom].freeze
  TYPE_KEYS = %w[income expense transfer].freeze
  SORT_KEYS = %w[date_desc date_asc amount_desc amount_asc].freeze
  DEFAULT_SORT = 'date_desc'

  attr_reader :user, :params, :date_range_error

  def initialize(user:, params:)
    @user = user
    @params = params
    @date_range_error = nil
  end

  def date_range
    params[:date_range].presence_in(DATE_RANGE_KEYS) || 'this_month'
  end

  def type
    params[:type].presence_in(TYPE_KEYS)
  end

  def sort
    params[:sort].presence_in(SORT_KEYS) || DEFAULT_SORT
  end

  def account_id
    id = int_param(:account_id)
    return if id.blank?

    id if allowed_account_ids.include?(id)
  end

  def category_id
    id = int_param(:category_id)
    return if id.blank?

    id if allowed_category_ids.include?(id)
  end

  def account_options
    user.asset_accounts.order(:name).to_a + user.person_accounts.order(:name).to_a
  end

  def category_options
    (user.expense_accounts.to_a + user.income_accounts.to_a).uniq.sort_by(&:name)
  end

  def scope
    base = Transaction
           .where(user:)
           .includes(:credit_account, :debit_account)

    base = apply_type(base)
    base = apply_date(base)
    base = apply_account(base)
    base = apply_category(base)
    apply_sort(base)
  end

  def resettable?
    type.present? ||
      params[:from_date].present? ||
      params[:to_date].present? ||
      (params[:date_range].present? && date_range != 'this_month') ||
      params[:page].to_i > 1 ||
      account_id.present? ||
      category_id.present? ||
      sort != DEFAULT_SORT ||
      dirty_account_param? ||
      dirty_category_param? ||
      dirty_sort_param?
  end

  private

  def int_param(key)
    val = params[key]
    return if val.blank?

    Integer(val)
  rescue ArgumentError, TypeError
    nil
  end

  def allowed_account_ids
    @allowed_account_ids ||= (user.asset_accounts.pluck(:id) + user.person_accounts.pluck(:id)).uniq
  end

  def allowed_category_ids
    @allowed_category_ids ||= (user.expense_accounts.pluck(:id) + user.income_accounts.pluck(:id)).uniq
  end

  def dirty_account_param?
    params[:account_id].present? && account_id.nil?
  end

  def dirty_category_param?
    params[:category_id].present? && category_id.nil?
  end

  def dirty_sort_param?
    params[:sort].present? && params[:sort].to_s.presence_in(SORT_KEYS).nil?
  end

  def apply_type(rel)
    return rel if type.blank?

    rel.where(transaction_type: type)
  end

  def apply_date(rel)
    return rel if date_range == 'custom' && custom_dates_incomplete?

    if date_range == 'custom'
      from = parse_date(params[:from_date])
      to = parse_date(params[:to_date])
      if from && to && from > to
        @date_range_error = 'Start date must be on or before end date.'
        return rel.none
      end
      return rel.within(from, to) if from && to

      return rel
    end

    start_d, end_d = preset_range_bounds
    rel.within(start_d, end_d)
  end

  def apply_account(rel)
    return rel if account_id.blank?

    rel.where('credit_account_id = :aid OR debit_account_id = :aid', aid: account_id)
  end

  def apply_category(rel)
    return rel if category_id.blank?

    rel.where(
      "(transaction_type = 'expense' AND debit_account_id = :cid) OR (transaction_type = 'income' AND credit_account_id = :cid)",
      cid: category_id
    )
  end

  def apply_sort(rel)
    case sort
    when 'date_asc'
      rel.order(transaction_date: :asc, id: :asc)
    when 'amount_desc'
      rel.order(amount: :desc, id: :desc)
    when 'amount_asc'
      rel.order(amount: :asc, id: :asc)
    else
      rel.order(transaction_date: :desc, id: :desc)
    end
  end

  def custom_dates_incomplete?
    params[:from_date].blank? || params[:to_date].blank?
  end

  def preset_range_bounds
    today = Time.zone.today
    case date_range
    when 'last_7_days'
      [today - 6.days, today]
    when 'this_month'
      [today.beginning_of_month, today.end_of_month]
    when 'last_month'
      m = today.last_month
      [m.beginning_of_month, m.end_of_month]
    else
      [today.beginning_of_month, today.end_of_month]
    end
  end

  def parse_date(value)
    return if value.blank?

    Time.zone.parse(value.to_s)&.to_date
  rescue ArgumentError
    nil
  end
end
