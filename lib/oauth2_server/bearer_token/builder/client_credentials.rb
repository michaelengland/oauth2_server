module Oauth2Server
  module BearerToken
    module Builder
      class ClientCredentials < Base
        def token
          Entities::Token.new(
            client,
            'client_credentials',
            generate_hex,
            refresh: generate_hex
          )
        end
      end
    end
  end
end
