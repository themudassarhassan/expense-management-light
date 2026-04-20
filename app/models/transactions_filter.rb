# frozen_string_literal: true

class TransactionsFilter
  DATE_RANGE_KEYS = %w[last_7_days this_month last_month custom].freeze
  TYPE_KEYS = %w[income expense transfer].freeze

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

  def scope
    base = Transaction
           .where(user:)
           .includes(:credit_account, :debit_account)
           .order(created_at: :desc)

    base = apply_type(base)
    apply_date(base)
  end

  def resettable?
    params[:type].present? ||
      params[:from_date].present? ||
      params[:to_date].present? ||
      (params[:date_range].present? && date_range != 'this_month') ||
      params[:page].to_i > 1
  end

  private

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
