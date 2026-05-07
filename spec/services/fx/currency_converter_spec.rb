# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fx::CurrencyConverter do
  before do
    allow(Fx::ExchangeRates).to receive(:fetch).and_return(
      base: 'EUR',
      date: Time.zone.today.to_s,
      rates: {
        'USD' => BigDecimal('1.20'),
        'PKR' => BigDecimal('300')
      }
    )
  end

  it 'returns the same numeric value when currencies match' do
    expect(described_class.convert(42, from: 'PKR', to: 'PKR')).to eq(42)
  end

  # 300 PKR = 1 EUR; 120 USD = EUR * 1.2 ⇒ 1 EUR ≈ USD/1.2
  it 'converts PKR to USD via the pivot currency' do
    # 600 PKR = 2 EUR; 2 * 1.2 = 2.4 USD
    expect(described_class.convert(600, from: 'PKR', to: 'USD')).to eq(BigDecimal('2.40'))
  end

  it 'raises when a quote currency is missing from cached rates' do
    allow(Fx::ExchangeRates).to receive(:fetch).and_return(
      base: 'EUR',
      date: Time.zone.today.to_s,
      rates: { 'USD' => BigDecimal('1') }
    )

    expect do
      described_class.convert(10, from: 'PKR', to: 'USD')
    end.to raise_error(Fx::UnavailableError)
  end
end
