# frozen_string_literal: true

# :rack_test shares the test DB process with the app (Capybara), so transactional fixtures
# work. Use headless browser only for flows that need JavaScript.
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end

Capybara.default_max_wait_time = 2
