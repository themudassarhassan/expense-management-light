# frozen_string_literal: true

module TransactionsHelper
  BADGE_BASE = "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset capitalize"

  FILTER_SEGMENT_BASE =
    "inline-flex items-center justify-center rounded-md px-3 py-1.5 text-sm font-semibold transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2"

  DATE_RANGE_FILTER_OPTIONS = [
    ['Last 7 days', 'last_7_days'],
    ['This month', 'this_month'],
    ['Last month', 'last_month'],
    ['Custom range', 'custom']
  ].freeze

  def transaction_date_range_filter_options
    DATE_RANGE_FILTER_OPTIONS
  end

  def transactions_filtered_path(**overrides)
    overrides = overrides.symbolize_keys
    reset_page = overrides.delete(:reset_page)
    clear_type = overrides.delete(:clear_type)
    clear_account = overrides.delete(:clear_account)
    clear_category = overrides.delete(:clear_category)
    src = request.query_parameters
    sort_src = (src[:sort].presence || src['sort'].presence).to_s
    sort_q =
      if sort_src.present? && sort_src.in?(TransactionsFilter::SORT_KEYS) && sort_src != TransactionsFilter::DEFAULT_SORT
        sort_src
      end

    q = {
      date_range: src[:date_range].presence || src['date_range'].presence,
      from_date: src[:from_date].presence || src['from_date'].presence,
      to_date: src[:to_date].presence || src['to_date'].presence,
      type: src[:type].presence || src['type'].presence,
      page: src[:page].presence || src['page'].presence,
      account_id: src[:account_id].presence || src['account_id'].presence,
      category_id: src[:category_id].presence || src['category_id'].presence,
      sort: sort_q
    }.compact

    overrides.each do |key, val|
      if val.nil?
        q.delete(key)
      elsif key == :sort && val.to_s == TransactionsFilter::DEFAULT_SORT
        q.delete(:sort)
      else
        q[key] = val
      end
    end
    q.delete(:type) if clear_type
    q.delete(:account_id) if clear_account
    q.delete(:category_id) if clear_category
    q.delete(:page) if reset_page
    transactions_path(q)
  end

  # Sort order is changed only via Amount/Date column headers on the table (not filter pills).
  def transactions_sort_header_path(f, column)
    new_sort =
      case column.to_sym
      when :date
        if f.sort == 'date_desc'
          'date_asc'
        elsif f.sort == 'date_asc'
          'date_desc'
        else
          'date_desc'
        end
      when :amount
        if f.sort == 'amount_desc'
          'amount_asc'
        elsif f.sort == 'amount_asc'
          'amount_desc'
        else
          'amount_desc'
        end
      end
    if new_sort == TransactionsFilter::DEFAULT_SORT
      transactions_filtered_path(sort: nil, reset_page: true)
    else
      transactions_filtered_path(sort: new_sort, reset_page: true)
    end
  end

  def transaction_sort_header_link_classes
    'group inline-flex items-center gap-1 rounded-md text-sm font-semibold text-gray-900 hover:text-indigo-600 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:text-gray-200 dark:hover:text-indigo-400 dark:focus-visible:outline-indigo-500'
  end

  def transaction_sort_column_aria_sort(f, column)
    case column.to_sym
    when :date
      return unless f.sort.start_with?('date')

      f.sort == 'date_asc' ? 'ascending' : 'descending'
    when :amount
      return unless f.sort.start_with?('amount')

      f.sort == 'amount_asc' ? 'ascending' : 'descending'
    end
  end

  def transaction_sort_indicator_visible?(f, column)
    case column.to_sym
    when :date
      f.sort.start_with?('date')
    when :amount
      f.sort.start_with?('amount')
    end
  end

  def transaction_sort_indicator_rotate_for_asc?(f, column)
    case column.to_sym
    when :date
      f.sort == 'date_asc'
    when :amount
      f.sort == 'amount_asc'
    end
  end

  def transaction_filter_segment_classes(active)
    if active
      "#{FILTER_SEGMENT_BASE} bg-indigo-600 text-white focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:focus-visible:outline-indigo-500"
    else
      "#{FILTER_SEGMENT_BASE} bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus-visible:outline-indigo-600 dark:bg-white/5 dark:text-gray-200 dark:ring-white/10 dark:hover:bg-white/10 dark:focus-visible:outline-indigo-500"
    end
  end

  # Date presets use link navigation (consistent with other Turbo frame filters).
  def transactions_date_range_filter_path(date_range_key)
    transactions_filtered_path(
      date_range: date_range_key,
      reset_page: true,
      from_date: nil,
      to_date: nil
    )
  end

  def transaction_type_badge_classes(transaction_type)
    case transaction_type.to_s
    when "income"
      "#{BADGE_BASE} bg-emerald-50 text-emerald-700 ring-emerald-600/20 dark:bg-emerald-500/10 dark:text-emerald-400 dark:ring-emerald-500/25"
    when "expense"
      "#{BADGE_BASE} bg-red-50 text-red-700 ring-red-600/20 dark:bg-red-500/10 dark:text-red-400 dark:ring-red-500/25"
    when "transfer"
      "#{BADGE_BASE} bg-sky-50 text-sky-700 ring-sky-600/20 dark:bg-sky-500/10 dark:text-sky-400 dark:ring-sky-500/25"
    else
      "#{BADGE_BASE} bg-slate-50 text-slate-700 ring-slate-600/20 dark:bg-slate-500/10 dark:text-slate-400 dark:ring-slate-500/25"
    end
  end

  def transaction_amount_classes(transaction_type, font_weight: :medium)
    bold = font_weight == :bold
    weight = bold ? "font-bold" : "font-medium"
    case transaction_type.to_s
    when "income"
      "#{weight} text-emerald-700 tabular-nums dark:text-emerald-400"
    when "expense"
      "#{weight} text-red-700 tabular-nums dark:text-red-400"
    when "transfer"
      "#{weight} text-sky-700 tabular-nums dark:text-sky-400"
    else
      bold ? "font-bold text-gray-900 tabular-nums dark:text-white" : "text-gray-900 tabular-nums dark:text-white"
    end
  end
end
