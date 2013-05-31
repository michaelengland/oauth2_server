require 'active_support/core_ext/object/blank'

module Oauth2Server
  module BearerToken
    module Builder
      class Password < Base
        def token
          Entities::Token.new(
            client,
            'password',
            generate_hex,
            refresh: generate_hex,
            resource_owner: resource_owner
          )
        end

        private

        def resource_owner
          retrieve_resource_owner || raise_invalid_grant_error
        end

        def retrieve_resource_owner
          resource_owner_repositories.inject(nil) { |resource_owner, repository|
            resource_owner || repository.find_by_username_and_password(username, password)
          }
        end

        def username
          required_param('username')
        end

        def password
          required_param('password')
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
      end
    end
  end
end
