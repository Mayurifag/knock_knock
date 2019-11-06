# frozen_string_literal: true

require_dependency "jwt"

module KnockKnock
  class AuthToken
    attr_reader :token, :payload

    def initialize(payload: {}, token: nil, verify_options: {})
      if token.present?
        @payload, _ = JWT.decode token.to_s, decode_key, true, options.merge(verify_options)
        @token = token
      else
        @payload = claims.merge(payload)
        @token = JWT.encode @payload,
          secret_key,
          KnockKnock.token_signature_algorithm
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

    def options
      verify_claims.merge(
        algorithm: KnockKnock.token_signature_algorithm,
      )
    end

    def claims
      claims_hash = {}
      claims_hash[:exp] = token_lifetime if verify_lifetime?
      claims_hash[:aud] = token_audience if verify_audience?
      claims_hash
    end

    def token_lifetime
      KnockKnock.token_lifetime.from_now.to_i if verify_lifetime?
    end

    def verify_lifetime?
      KnockKnock.token_lifetime.present?
    end

    def verify_claims
      {
        aud: token_audience,
        verify_aud: verify_audience?,
        verify_expiration: verify_lifetime?,
      }
    end

    def token_audience
      verify_audience? && KnockKnock.token_audience.call
    end

    def verify_audience?
      KnockKnock.token_audience.present?
    end
  end
end
