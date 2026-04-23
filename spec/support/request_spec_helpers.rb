# frozen_string_literal: true

module RequestSpecHelpers
  def sign_in_as(user, password: '1234345')
    post session_path, params: { email: user.email, password: }
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelpers, type: :request
end
