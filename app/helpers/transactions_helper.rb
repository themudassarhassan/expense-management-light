# frozen_string_literal: true

module TransactionsHelper
  BADGE_BASE = "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset capitalize"

  FILTER_SEGMENT_BASE =
    "inline-flex items-center justify-center rounded-md px-3 py-1.5 text-sm font-semibold transition-colors focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2"

  def transactions_filtered_path(**overrides)
    overrides = overrides.symbolize_keys
    reset_page = overrides.delete(:reset_page)
    clear_type = overrides.delete(:clear_type)
    src = request.query_parameters
    q = {
      date_range: src[:date_range].presence || src['date_range'].presence,
      from_date: src[:from_date].presence || src['from_date'].presence,
      to_date: src[:to_date].presence || src['to_date'].presence,
      type: src[:type].presence || src['type'].presence,
      page: src[:page].presence || src['page'].presence
    }.compact

    overrides.each do |key, val|
      if val.nil?
        q.delete(key)
      else
        q[key] = val
      end
    end
    q.delete(:type) if clear_type
    q.delete(:page) if reset_page
    transactions_path(q)
  end

  def transaction_filter_segment_classes(active)
    if active
      "#{FILTER_SEGMENT_BASE} bg-indigo-600 text-white focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:focus-visible:outline-indigo-500"
    else
      "#{FILTER_SEGMENT_BASE} bg-white text-gray-700 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus-visible:outline-indigo-600 dark:bg-white/5 dark:text-gray-200 dark:ring-white/10 dark:hover:bg-white/10 dark:focus-visible:outline-indigo-500"
    end
  end

  def transaction_date_range_select_classes
    "block rounded-md border-0 bg-white py-2 pr-8 pl-3 text-sm font-medium text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 dark:bg-white/5 dark:text-white dark:ring-white/10 dark:focus:ring-indigo-500"
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
