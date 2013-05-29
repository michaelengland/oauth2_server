require 'active_support/core_ext/object/blank'

module Oauth2Server
  module BearerToken
    module TokenBuilder
      class Password < Base
        def token
          Entities::Token.new(
            client,
            'password',
            generate_code,
            refresh: generate_code,
            resource_owner: resource_owner
          )
        end

        private

        def resource_owner
          retriever_resource_owner || raise_invalid_grant_error
        end

        def retriever_resource_owner
          resource_owner_repositories.inject(nil) { |resource_owner, repository|
            resource_owner || repository.find_resource_owner_by_username_and_password(username, password)
          }
        end

        def username
          param('username')
        end

        def password
          param('password')
        end

        def param(key)
          if request.params[key].present?
            request.params[key]
          else
            raise Errors::InvalidRequest.new(description: "Missing #{key}")
          end
        end

        def resource_owner_repositories
          if options.has_key?(:resource_owner_repository)
            Array(options[:resource_owner_repository])
          elsif options.has_key?(:resource_owner_repositories)
            options[:resource_owner_repositories]
          elsif options.has_key?(:configuration)
            options[:configuration].registered_resource_owner_repositories
          else
            Oauth2Server.configuration.registered_resource_owner_repositories
          end
        end

        def raise_invalid_grant_error
          raise Errors::InvalidGrant
        end
      end
    end
  end
end