module KnockKnock
  class Claims
    class << self
      def to_encode
        claims = {}
        claims[:exp] = token_lifetime if verify_lifetime?
        claims[:aud] = token_audience if verify_audience?
        claims
      end

      def to_decode
        {
          algorithm: KnockKnock.token_signature_algorithm,
          aud: token_audience,
          verify_aud: verify_audience?,
          verify_expiration: verify_lifetime?
        }
      end

      private

      def token_lifetime
        KnockKnock.token_lifetime.from_now.to_i if verify_lifetime?
      end

      def verify_lifetime?
        KnockKnock.token_lifetime.present?
      end

      def token_audience
        verify_audience? && KnockKnock.token_audience.call
      end

      def verify_audience?
        KnockKnock.token_audience.present?
      end
    end
  end
end
