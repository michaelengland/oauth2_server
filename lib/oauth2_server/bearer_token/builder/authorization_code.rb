require 'active_support/core_ext/object/blank'

module Oauth2Server
  module BearerToken
    module Builder
      class AuthorizationCode < Base
        def token
          Entities::Token.new(
            client,
            'authorization_code',
            generate_hex,
            refresh: generate_hex,
            resource_owner: resource_owner
          )
        end

        private

        def resource_owner
          authorization_grant.resource_owner
        end

        def authorization_grant
          authorization_grant = retriever_authorization_grant
          if authorization_grant.blank?
            raise_invalid_grant_error
          elsif authorization_grant.redirect_uri.present? && authorization_grant.redirect_uri != redirect_uri
            raise_redirect_uri_mismatch_error
          end
          authorization_grant
        end

        def retriever_authorization_grant
          authorization_grant_repositories.inject(nil) { |authorization_grant, repository|
            authorization_grant || repository.find_by_client_and_code(client, code)
          }
        end

        def code
          required_param('code')
        end

        def redirect_uri
          required_param('redirect_uri')
        end

        def authorization_grant_repositories
          if options.has_key?(:authorization_grant_repository)
            Array(options[:authorization_grant_repository])
          elsif options.has_key?(:authorization_grant_repositories)
            options[:authorization_grant_repositories]
          elsif options.has_key?(:configuration)
            options[:configuration].registered_authorization_grant_repositories
          else
            Oauth2Server.configuration.registered_authorization_grant_repositories
          end
        end

        def raise_redirect_uri_mismatch_error
          raise_invalid_grant_error('Redirect uri does not match')
        end
      end
    end
  end
end
