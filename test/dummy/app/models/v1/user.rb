# frozen_string_literal: true

module V1
  class User < ApplicationRecord
    has_secure_password
  end
end
