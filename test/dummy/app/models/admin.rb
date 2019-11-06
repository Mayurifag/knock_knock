# frozen_string_literal: true

class Admin < ApplicationRecord
  has_secure_password

  def self.from_token_request(request)
    email = request.params["auth"] && request.params["auth"]["email"]
    find_by email: email
  end

  def self.from_token_payload(payload)
    find payload["sub"]
  end

  def to_token_payload
    {sub: id}
  end
end
