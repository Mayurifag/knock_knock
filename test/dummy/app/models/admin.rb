# frozen_string_literal: true

class Admin < ApplicationRecord
  has_secure_password

  def self.from_token_request(request)
    find_by email: request.params["email"]
  end

  def self.from_token_payload(payload)
    find payload["sub"]
  end

  def to_token_payload
    {sub: id}
  end
end
