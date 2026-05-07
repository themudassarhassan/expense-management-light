# frozen_string_literal: true

require 'json'
require 'net/http'

module Fx
  # Frankfurter v2 returns an array: [{"date"=>"…","base"=>"EUR","quote"=>"USD","rate"=>…}, …]
  # Same interpretation as ECB v1: 1 BASE = rate units of QUOTE.
  #
  # v1 `latest` ECB feed omits some ISO codes (e.g. PKR); v2 includes them via blended providers.
  # Canonical host: api.frankfurter.dev (`api.frankfurter.app` 301s). See https://www.frankfurter.dev/docs/
  class FrankfurterClient
    SOURCE = URI.parse('https://api.frankfurter.dev/v2/rates')

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.fetch_latest(base: 'EUR')
      base_s = base.to_s.upcase
      quote_codes = CurrencyOptions::CODES.reject { |c| c == base_s }
      uri = SOURCE.dup
      uri.query = URI.encode_www_form(base: base_s, quotes: quote_codes.join(','))

      Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 10, open_timeout: 5) do |http|
        response = http.get(uri.request_uri)

        unless response.code == '200'
          raise Fx::UnavailableError,
                "Frankfurter returned HTTP #{response.code}"
        end

        rows = JSON.parse(response.body)
        unless rows.is_a?(Array) && rows.any?
          raise Fx::UnavailableError, 'Unexpected Frankfurter response shape'
        end

        rates = {}
        rows.each do |row|
          rates[row['quote'].to_s.upcase] = BigDecimal(row['rate'].to_s)
        end

        missing = quote_codes - rates.keys
        if missing.any?
          raise Fx::UnavailableError,
                "Frankfurter omitted rates for: #{missing.sort.join(', ')}"
        end

        date = rows.first['date']
        { base: base_s, date:, rates: }
      end
    end

    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
