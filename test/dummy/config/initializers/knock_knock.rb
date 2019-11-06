# frozen_string_literal: true

KnockKnock.setup do |config|
  config.token_signature_algorithm = "HS256"
  config.token_secret_signature_key = -> { Rails.application.credentials.fetch(:secret_key_base) }
  config.token_public_key = nil
  config.token_audience = nil

  config.not_found_exception_class_name = "ActiveRecord::RecordNotFound"
end
