# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fx::FrankfurterClient do
  describe '.fetch_latest' do
    let(:http) { instance_double(Net::HTTP) }
    let(:response) { instance_double(Net::HTTPResponse, code: '200', body: body_json) }
    let(:body_json) do
      [
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'PKR', 'rate' => 326.32 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'USD', 'rate' => 1.1698 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'GBP', 'rate' => 0.86281 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'AED', 'rate' => 4.2947 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'CAD', 'rate' => 1.5762 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'AUD', 'rate' => 1.7902 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'JPY', 'rate' => 184.42 },
        { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'CHF', 'rate' => 0.9165 }
      ].to_json
    end

    before do
      allow(Net::HTTP).to receive(:start)
        .with('api.frankfurter.dev', 443, hash_including(use_ssl: true))
        .and_yield(http)
      allow(http).to receive(:get).and_return(response)
    end

    it 'returns normalized base, date, and rates including PKR' do
      result = described_class.fetch_latest(base: 'EUR')

      expect(result[:base]).to eq('EUR')
      expect(result[:date]).to eq('2026-05-06')
      expect(result[:rates]['PKR']).to eq(BigDecimal('326.32'))
      expect(result[:rates]['USD']).to eq(BigDecimal('1.1698'))
      expect(result[:rates].keys.sort).to eq(
        %w[AED AUD CAD CHF GBP JPY PKR USD]
      )
    end

    context 'when a quoted currency is missing' do
      let(:body_json) do
        [
          { 'date' => '2026-05-06', 'base' => 'EUR', 'quote' => 'USD', 'rate' => 1.0 }
        ].to_json
      end

      it 'raises UnavailableError' do
        expect do
          described_class.fetch_latest(base: 'EUR')
        end.to raise_error(Fx::UnavailableError, /omitted rates/)
      end
    end
  end
end
