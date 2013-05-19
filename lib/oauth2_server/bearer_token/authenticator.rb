require 'active_support/core_ext/object/blank'

module Oauth2Server
  module BearerToken
    class Authenticator
      BEARER_TOKEN_REGEX = '[a-zA-Z0-9]*'
      HTTP_AUTHORIZATION_REGEX = "(OAuth|Bearer) (#{BEARER_TOKEN_REGEX})"

      def initialize(request, options = {})
        @request = request
        @options = options
      end

      def token
        @_token ||= begin
          retrieve_token || raise_invalid_token_error
        end
      end

      alias_method :authenticate!, :token

      private
      attr_reader :request, :options

      def retrieve_token
        token_repositories.inject(nil) { |token, repository|
          token || repository.find_token_by_access(token_access)
        }
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

      def token_access
        @_token_access ||= begin
          if authorization_header_token.present?
            authorization_header_token
          elsif oauth_token_param.present?
            oauth_token_param
          elsif access_token_param.present?
            access_token_param
          else
            raise_missing_token_error
          end
        end
      end

      def authorization_header_token
        if authorization_header =~ /#{HTTP_AUTHORIZATION_REGEX}/
          $2
        end
      end

      def authorization_header
        request.env['HTTP_AUTHORIZATION'] ||
          request.env['X-HTTP_AUTHORIZATION'] ||
          request.env['X_HTTP_AUTHORIZATION'] ||
          request.env['REDIRECT_X_HTTP_AUTHORIZATION']
      end

      def oauth_token_param
        request.params['oauth_token']
      end

      def access_token_param
        request.params['access_token']
      end

      def raise_invalid_token_error
        raise Errors::InvalidToken
      end

      def raise_missing_token_error
        raise Errors::TokenMissing
      end
    end
  end
end
