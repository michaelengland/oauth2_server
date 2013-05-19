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
  end
end
