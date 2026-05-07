# frozen_string_literal: true

module Dashboard
  # Headline numbers for the dashboard. See Dashboard::Snapshot for usage.
  #
  # Total balance in base currency: sum of current_balance for asset + person accounts,
  # each converted to User#base_currency via Frankfurter (cached).
  # Category ledgers are excluded (same as before).
  #
  # Monthly income / expense sums are still raw transaction amounts (mixed-currency caveat).
  class Metrics
    OVERVIEW_ACCOUNT_TYPES = (Account::ASSET_TYPES + [Account::PERSON_TYPE]).freeze

    attr_reader :user, :month_start

    def initialize(user, month_start = Time.zone.today.beginning_of_month)
      @user = user
      @month_start = month_start.to_date
    end

    def total_balance
      user.accounts.where(account_type: OVERVIEW_ACCOUNT_TYPES).inject(BigDecimal('0')) do |sum, account|
        sum + Fx::CurrencyConverter.convert(
          account.current_balance.to_d,
          from: account.currency_code,
          to: user.base_currency
        )
      end
    rescue Fx::UnavailableError
      nil
    end

    def monthly_income
      monthly_type_totals.fetch('income', 0).to_d
    end

    def monthly_expense
      monthly_type_totals.fetch('expense', 0).to_d
    end

    def monthly_net
      monthly_income - monthly_expense
    end

    private

    def monthly_type_totals
      @monthly_type_totals ||= user.transactions
                                   .where(transaction_date: month_start.all_month)
                                   .where(transaction_type: %w[income expense])
                                   .group(:transaction_type)
                                   .sum(:amount)
                                   .transform_keys(&:to_s)
                                   .transform_values { |v| BigDecimal(v.to_s) }
    end
  end
end
