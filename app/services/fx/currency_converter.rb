# frozen_string_literal: true

module Fx
  # Converts nominal amounts via Frankfurter's quoted rates map (PIPELINE_FROM as API base).
  class CurrencyConverter
    def self.convert(amount, from:, to:)
      from_s = from.to_s.strip.upcase
      to_s = to.to_s.strip.upcase

      amt = BigDecimal(amount.to_s)
      return amt if from_s == to_s

      payload = Fx::ExchangeRates.fetch
      pivot_amt = in_pivot_units(amt, from_s, payload)
      result = from_pivot_units(pivot_amt, to_s, payload)

      result.round(2, BigDecimal::ROUND_HALF_EVEN)
    end

    def self.in_pivot_units(amount, currency, payload)
      pivot = payload[:base]

      return amount if currency == pivot

      rate = quoted_per_base(payload[:rates], currency)
      raise Fx::UnavailableError, "Missing rate for #{currency}" unless rate

      # One pivot buys `rate` units of `currency`; reverse: currency ÷ rate = pivot float.
      amount / rate
    end

    def self.from_pivot_units(pivot_amount, currency, payload)
      pivot = payload[:base]

      return pivot_amount if currency == pivot

      rate = quoted_per_base(payload[:rates], currency)
      raise Fx::UnavailableError, "Missing rate for #{currency}" unless rate

      pivot_amount * rate
    end

    def self.quoted_per_base(rates, quote)
      key = quote.to_s.upcase
      return nil if rates.blank?

      BigDecimal(rates.fetch(key).to_s)
    rescue ArgumentError, KeyError
      nil
    end

    private_class_method :quoted_per_base, :in_pivot_units, :from_pivot_units
  end
end
