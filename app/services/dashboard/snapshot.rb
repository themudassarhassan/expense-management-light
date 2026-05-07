# frozen_string_literal: true

module Dashboard
  class Snapshot
    attr_reader :user, :month_start

    def initialize(user, month_start: Time.zone.today.beginning_of_month)
      @user = user
      @month_start = month_start.to_date
    end

    def metrics
      @metrics ||= Metrics.new(user, month_start)
    end

    def recent_transactions
      @recent_transactions ||= user.transactions
                                   .where(transaction_date: month_start.all_month)
                                   .includes(:credit_account, :debit_account)
                                   .order(transaction_date: :desc, created_at: :desc)
                                   .limit(7)
    end

    def overview_accounts
      @overview_accounts ||= user.accounts
                                 .where(account_type: Metrics::OVERVIEW_ACCOUNT_TYPES)
                                 .order(:name)
                                 .to_a
    end

    # [[account, native_balance], …] — balances in each account’s currency.
    def overview_accounts_with_balances
      @overview_accounts_with_balances ||= overview_accounts.map { |a| [a, a.current_balance.to_d] }
    end

    def month_budgets
      @month_budgets ||= user.budgets.includes(:account).where(budget_month: month_start).order(:amount)
    end

    def no_overview_accounts?
      overview_accounts.empty?
    end

    def no_transactions?
      !user.transactions.exists?
    end

    def no_budgets_this_month?
      month_budgets.empty?
    end

    def highest_balance_account_id
      pairs = overview_accounts_with_balances
      return if pairs.empty?

      pairs.max_by { |account, bal| rank_balance(account, bal) }&.first&.id
    end

    # Denominator for "% of total" bars: sum of converted absolute balances in user base currency,
    # falling back to native abs if FX is unavailable.
    def overview_converted_total_abs
      overview_accounts_with_balances.sum { |account, bal| rank_balance(account, bal).abs.to_d }
    end

    # Comparable weight in base currency for share % (non-negative).
    def share_weight(account, native_balance)
      rank_balance(account, native_balance).abs
    end

    private

    def rank_balance(account, native_balance)
      Fx::CurrencyConverter.convert(
        native_balance.to_d,
        from: account.currency_code,
        to: user.base_currency
      )
    rescue Fx::UnavailableError
      native_balance.to_d
    end
  end
end
