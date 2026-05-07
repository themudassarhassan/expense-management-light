# frozen_string_literal: true

# ECB-style nominal rates: amounts are EUR (base); `rates[Q]` equals how many units of Q per 1 EUR.
module FxTestRates
  EUR_BASE_PAYLOAD = {
    base: 'EUR',
    date: Time.zone.today.to_s,
    rates: {
      'USD' => BigDecimal('1.1'),
      'GBP' => BigDecimal('0.85'),
      'PKR' => BigDecimal('300'),
      'AED' => BigDecimal('4'),
      'CAD' => BigDecimal('1.45'),
      'AUD' => BigDecimal('1.65'),
      'JPY' => BigDecimal('160'),
      'CHF' => BigDecimal('0.96')
    }.freeze
  }.freeze
end

RSpec.configure do |config|
  config.before do
    allow(Fx::ExchangeRates).to receive(:fetch).and_return(FxTestRates::EUR_BASE_PAYLOAD)
  end
end
