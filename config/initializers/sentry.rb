# frozen_string_literal: true

return unless defined?(Sentry)

dsn = Rails.application.credentials.dig(:sentry, :dsn).presence

return if dsn.blank?

Sentry.init do |config|
  config.dsn = dsn
  config.environment = Rails.env
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.traces_sample_rate = 0.2

  release = ENV.fetch('GIT_SHA', nil).presence || ENV.fetch('SENTRY_RELEASE', nil).presence
  config.release = release if release
end
