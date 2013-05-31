module Oauth2Server
  module BearerToken
    module TokenBuilder
      class Factory
        def initialize(client, request, options)
          @client = client
          @request = request
          @options = options
        end

        def token_builder
          case grant_type
            when 'client_credentials'
              ClientCredentials.new(client, request, options)
            when 'password'
              Password.new(client, request, options)
            when 'authorization_code'
              AuthorizationCode.new(client, request, options)
            when 'refresh_token'
              RefreshToken.new(client, request, options)
            else
              raise Errors::UnsupportedGrantType
          end
        end

        private
        attr_reader :client, :request, :options

        def grant_type
          if grant_type_param.present?
            grant_type_param
          else
            raise_missing_grant_type_param
          end
        end

        def grant_type_param
          request.params['grant_type']
        end

        def raise_missing_grant_type_param
          raise Errors::InvalidRequest.new(description: 'Missing grant_type')
        end
      end
    end
  end
end
