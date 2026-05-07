# frozen_string_literal: true

module Fx
  PIPELINE_FROM = ENV.fetch('FRANKFURTER_FROM', 'EUR').freeze

  CACHE_KEY = "fx/frankfurter/v2/#{PIPELINE_FROM}".freeze

  TTL = 1.day.freeze

  # Daily Frankfurter rates cached via Rails.cache (memory / Redis elsewhere).
  class ExchangeRates
    def self.fetch
      Rails.cache.fetch(CACHE_KEY, expires_in: TTL) do
        FrankfurterClient.fetch_latest(base: PIPELINE_FROM)
      end
    rescue StandardError => e
      Rails.logger&.warn("#{name}: #{e.class}: #{e.message}")
      raise Fx::UnavailableError, 'Exchange rates are unavailable.'
    end
  end
end
