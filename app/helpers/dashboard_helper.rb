# frozen_string_literal: true

module DashboardHelper
  include TransactionsHelper

  def dashboard_card_classes
    'rounded-xl border border-gray-200 bg-white p-4 shadow-sm dark:border-white/10 dark:bg-gray-800/50'
  end

  def dashboard_section_heading_classes
    'text-base font-semibold text-gray-900 dark:text-gray-100'
  end

  def dashboard_budget_status(spent, limit)
    return :safe if limit.blank? || limit.to_d.zero?

    ratio = spent.to_d / limit.to_d
    return :over if ratio > 1
    return :warn if ratio >= 0.8

    :safe
  end

  def dashboard_budget_bar_outer_classes(status)
    base = 'h-2 w-full overflow-hidden rounded-full bg-gray-200 dark:bg-white/10'
    case status
    when :over then "#{base} ring-1 ring-red-200 dark:ring-red-900/40"
    when :warn then "#{base} ring-1 ring-amber-200 dark:ring-amber-900/40"
    else base
    end
  end

  def dashboard_budget_bar_inner_classes(status)
    case status
    when :over then 'h-full rounded-full bg-red-500 transition-all dark:bg-red-400'
    when :warn then 'h-full rounded-full bg-amber-400 transition-all dark:bg-amber-500'
    else 'h-full rounded-full bg-emerald-500 transition-all dark:bg-emerald-400'
    end
  end

  def dashboard_budget_bar_width_percent(spent, limit)
    return 0 if limit.blank? || limit.to_d.zero?

    [[spent.to_d / limit.to_d * 100, 100].min, 0].max.to_f
  end

  def dashboard_account_share_percent(weight, total_abs)
    return if total_abs.blank? || total_abs.to_d.zero?

    ((weight.to_d.abs / total_abs.to_d) * 100).round(1)
  end
end
