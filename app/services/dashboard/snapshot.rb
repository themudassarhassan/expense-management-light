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

    # [[account, balance], ...] — balances computed once per account for overview + % share.
    def overview_accounts_with_balances
      @overview_accounts_with_balances ||= overview_accounts.map { |a| [a, a.current_balance] }
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

      pairs.max_by { |(_, bal)| bal.to_d }&.first&.id
    end
  end
end
