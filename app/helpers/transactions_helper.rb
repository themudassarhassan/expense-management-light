# frozen_string_literal: true

module TransactionsHelper
  BADGE_BASE = "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset capitalize"

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

  def transaction_amount_classes(transaction_type)
    case transaction_type.to_s
    when "income"
      "font-medium text-emerald-700 tabular-nums dark:text-emerald-400"
    when "expense"
      "font-medium text-red-700 tabular-nums dark:text-red-400"
    when "transfer"
      "font-medium text-sky-700 tabular-nums dark:text-sky-400"
    else
      "text-gray-900 tabular-nums dark:text-white"
    end
  end
end
