# frozen_string_literal: true

require "test_helper"
require "jwt"
require "timecop"

module KnockKnock
  class AuthTokenTest < ActiveSupport::TestCase
    setup do
      key = KnockKnock.token_secret_signature_key.call
      @token = JWT.encode({sub: "1"}, key, "HS256")
    end

    test "verify algorithm" do
      KnockKnock.token_signature_algorithm = "RS256"

      assert_raises(JWT::IncorrectAlgorithm) do
        AuthToken.new(token: @token)
      end
    end

    test "decode RSA encoded tokens" do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      KnockKnock.token_public_key = rsa_private.public_key
      KnockKnock.token_signature_algorithm = "RS256"

      token = JWT.encode({sub: "1"}, rsa_private, "RS256")

      assert_nothing_raised { AuthToken.new(token: token) }
    end

    test "encode tokens with RSA" do
      rsa_private = OpenSSL::PKey::RSA.generate 2048
      KnockKnock.token_secret_signature_key = -> { rsa_private }
      KnockKnock.token_signature_algorithm = "RS256"

      token = AuthToken.new(payload: {sub: "1"}).token

      payload, header = JWT.decode token, rsa_private.public_key, true, algorithm: "RS256"
      assert_equal payload["sub"], "1"
      assert_equal header["alg"], "RS256"
    end

    test "verify audience when token_audience is present" do
      KnockKnock.token_audience = -> { "bar" }

      assert_raises(JWT::InvalidAudError) do
        AuthToken.new token: @token
      end
    end

    test "validate expiration claim by default" do
      token = AuthToken.new(payload: {sub: "foo"}).token
      Timecop.travel(25.hours.from_now) do
        assert_raises(JWT::ExpiredSignature) do
          AuthToken.new(token: token)
        end
      end
    end

    test "does not validate expiration claim with a nil token_lifetime" do
      KnockKnock.token_lifetime = nil

      token = AuthToken.new(payload: {sub: "foo"}).token
      Timecop.travel(10.years.from_now) do
        assert_not AuthToken.new(token: token).payload.key?("exp")
      end
    end

    test "validate aud when verify_options[:verify_aud] is true" do
      verify_options = {
        verify_aud: true,
      }
      KnockKnock.token_audience = -> { "bar" }
      KnockKnock.token_secret_signature_key.call
      assert_raises(JWT::InvalidAudError) do
        AuthToken.new token: @token, verify_options: verify_options
      end
    end

    test "does not validate aud when verify_options[:verify_aud] is false" do
      verify_options = {
        verify_aud: false,
      }
      KnockKnock.token_audience = -> { "bar" }
      KnockKnock.token_secret_signature_key.call
      assert_not AuthToken.new(token: @token, verify_options: verify_options).payload.key?("aud")
    end

    test "validate expiration when verify_options[:verify_expiration] is true" do
      verify_options = {
        verify_expiration: true,
      }
      token = AuthToken.new(payload: {sub: "foo"}).token
      Timecop.travel(25.hours.from_now) do
        assert_raises(JWT::ExpiredSignature) do
          AuthToken.new(token: token, verify_options: verify_options)
        end
      end
    end

    test "does not validate expiration when verify_options[:verify_expiration] is false" do
      verify_options = {
        verify_expiration: false,
      }
      token = AuthToken.new(payload: {sub: "foo"}).token
      Timecop.travel(25.hours.from_now) do
        assert AuthToken.new(token: token, verify_options: verify_options).payload.key?("exp")
      end
    end

    test "KnockKnock::AuthToken has all payloads" do
      KnockKnock.token_lifetime = 7.days
      payload = KnockKnock::AuthToken.new(payload: {sub: "foo"}).payload
      assert payload.key?(:sub)
      assert payload.key?(:exp)
    end

    test "is serializable" do
      auth_token = AuthToken.new token: @token

      assert_equal("{\"jwt\":\"#{@token}\"}", auth_token.to_json)
    end
  end
end
