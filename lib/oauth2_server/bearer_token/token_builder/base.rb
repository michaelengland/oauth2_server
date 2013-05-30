require 'rack'
require 'securerandom'

module Oauth2Server
  module BearerToken
    module TokenBuilder
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
      end
    end
  end
end
