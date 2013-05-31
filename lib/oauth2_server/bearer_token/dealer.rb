module Oauth2Server
  module BearerToken
    class Dealer
      def initialize(request, options = {})
        @request = request
        @options = options
      end

      def token
        @_token ||= begin
          save_token
          built_token
        end
      end

      alias_method :deal!, :token

      private
      attr_reader :request, :options

      def save_token
        token_repositories.each do |repository|
          repository.save_token(built_token)
        end
      end

      def token_repositories
        if options.has_key?(:token_repository)
          Array(options[:token_repository])
        elsif options.has_key?(:token_repositories)
          options[:token_repositories]
        elsif options.has_key?(:configuration)
          options[:configuration].registered_token_repositories
        else
          Oauth2Server.configuration.registered_token_repositories
        end
      end

      def built_token
        @_built_token ||= token_builder.token
      end

      def token_builder
        token_builder_factory.builder
      end

      def token_builder_factory
        Builder::Factory.new(client, request, options)
      end

      def client
        client_authenticator.client
      end

      def client_authenticator
        ClientAuthenticator.new(request, options)
      end
    end
  end
end
