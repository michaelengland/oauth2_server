module Oauth2Server
  module BearerToken
    module TokenBuilder
      class ClientCredentials < Base
        def token
          Entities::Token.new(
            client,
            'client_credentials',
            generate_code,
            refresh: generate_code
          )
        end
      end
    end
  end
end
