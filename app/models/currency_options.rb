# frozen_string_literal: true

# Supported ISO 4217 codes for account / profile selectors and Frankfurter conversions.
module CurrencyOptions
  CODES = %w[PKR USD EUR GBP AED CAD AUD JPY CHF].freeze

  LABELS = {
    'PKR' => 'Pakistani Rupee (PKR)',
    'USD' => 'US Dollar (USD)',
    'EUR' => 'Euro (EUR)',
    'GBP' => 'British Pound (GBP)',
    'AED' => 'UAE Dirham (AED)',
    'CAD' => 'Canadian Dollar (CAD)',
    'AUD' => 'Australian Dollar (AUD)',
    'JPY' => 'Japanese Yen (JPY)',
    'CHF' => 'Swiss Franc (CHF)'
  }.freeze

  def self.options_for_select
    CODES.map { |c| [LABELS.fetch(c), c] }
  end
end
