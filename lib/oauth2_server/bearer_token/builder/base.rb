require 'rack'
require 'securerandom'

module Oauth2Server
  module BearerToken
    module Builder
      class Base
        def initialize(client, request, options = {})
          @client = client
          @request = request
          @options = options
        end

        protected
        attr_reader :client, :request, :options

        def generate_hex
          SecureRandom.hex(token_length)
        end

        def required_param(key)
          if request.params[key].present?
            request.params[key]
          else
            raise_missing_param_error(key)
          end
        end

        def raise_invalid_grant_error(description = nil)
          raise Errors::InvalidGrant.new(description: description)
        end

        private

        def access
          generate_hex
        end

        def token_length
          if options.has_key?(:token_length)
            options[:token_length]
          elsif options.has_key?(:configuration)
            options[:configuration].token_length
          else
            Oauth2Server.configuration.token_length
          end
        end

        def raise_missing_param_error(key)
          raise Errors::InvalidRequest.new(description: "Missing #{key}")
        end
      end
    end
  end
end
