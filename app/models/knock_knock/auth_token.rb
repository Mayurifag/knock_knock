# frozen_string_literal: true

require_dependency "jwt"

module KnockKnock
  class AuthToken
    attr_reader :token, :payload

    def initialize(payload: {}, token: nil, verify_options: {})
      if token.present?
        @payload, _ = JWT.decode(token.to_s, decode_key, true, Claims.to_decode.merge(verify_options))
        @token = token
      else
        @payload = Claims.to_encode.merge(payload)
        @token = JWT.encode @payload, secret_key, KnockKnock.token_signature_algorithm
      end
    end

    def entity_for(entity_class)
      if entity_class.respond_to? :from_token_payload
        entity_class.from_token_payload @payload
      else
        entity_class.find @payload["sub"]
      end
    end

    def to_json(_options = {})
      {jwt: @token}.to_json
    end

    private

    def secret_key
      KnockKnock.token_secret_signature_key.call
    end

    def decode_key
      KnockKnock.token_public_key || secret_key
    end
  end
end
