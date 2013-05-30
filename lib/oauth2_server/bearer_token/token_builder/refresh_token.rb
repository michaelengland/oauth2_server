require 'active_support/core_ext/object/blank'

module Oauth2Server
  module BearerToken
    module TokenBuilder
      class RefreshToken < Base
        def token
          Entities::Token.new(
            client,
            'refresh_token',
            generate_hex,
            refresh: generate_hex,
            resource_owner: resource_owner
          )
        end

        private

        def resource_owner
          original_token.resource_owner
        end

        def original_token
          retrieve_original_token || raise_invalid_grant_error
        end

        def retrieve_original_token
          token_repositories.inject(nil) { |original_token, repository|
            original_token || repository.find_by_client_and_refresh(client, refresh_token)
          }
        end

        def refresh_token
          required_param('refresh_token')
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
      end
    end
  end
end
