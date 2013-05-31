module Oauth2Server
  module Errors
    class Oauth2Error < StandardError
      class << self
        attr_accessor :type, :status, :description
      end

      def initialize(options = {})
        @options = options
        super(description)
      end

      def type
        self.class.type
      end

      def status
        self.class.status || :unauthorized
      end

      def description
        @options[:description] || self.class.description
      end
    end

    class InsufficientScope < Oauth2Error
      self.type = :insufficient_scope
      self.status = :forbidden
      self.description = 'The request requires higher privileges than provided by the access token'

      attr_reader :scope

      def initialize(scope, options = {})
        @scope = scope
        super(options)
      end
    end

    class InvalidClient < Oauth2Error
      self.type = :invalid_client
    end

    class TokenMissing < Oauth2Error
      self.type = :token_missing
      self.description = 'You must provide a valid oauth token'
    end

    class InvalidToken < Oauth2Error
      self.type = :invalid_token
    end

    class InvalidGrant < Oauth2Error
      self.type = :invalid_grant
    end

    class InvalidRequest < Oauth2Error
      self.type = :invalid_request
      self.status = :bad_request
    end

    class UnsupportedGrantType < Oauth2Error
      self.type = :unsupported_grant_type
      self.status = :bad_request
      self.description = 'The authorization grant type is not supported'
    end
  end
end
