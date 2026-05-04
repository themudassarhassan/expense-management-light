# frozen_string_literal: true

# Pagy 3.x used `#prev`; Pagy 43 exposes `#previous` only. Support old view calls.
Rails.application.config.to_prepare do
  pagy_offset = Pagy::Offset
  next if pagy_offset.method_defined?(:prev)

  pagy_offset.alias_method :prev, :previous
end
