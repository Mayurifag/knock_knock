require "knock_knock/engine"
require_dependency "knock_knock/authenticable"

module KnockKnock
  mattr_accessor :token_lifetime
  self.token_lifetime = 1.day

  mattr_accessor :token_audience
  self.token_audience = nil

  mattr_accessor :token_signature_algorithm
  self.token_signature_algorithm = "HS256"

  mattr_accessor :token_secret_signature_key
  self.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }

  mattr_accessor :token_public_key
  self.token_public_key = nil

  mattr_accessor :not_found_exception_class_name
  self.not_found_exception_class_name = "ActiveRecord::RecordNotFound"

  def self.not_found_exception_class
    not_found_exception_class_name.to_s.constantize
  end

  # Default way to setup KnockKnock. Run `rails generate knock_knock:install` to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end
end
