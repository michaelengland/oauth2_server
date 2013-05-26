module Oauth2Server
  module BearerToken
    module TokenBuilder
      class ClientCredentials < Base
        protected

        def grant_type
          'client_credentials'
        end

        def token_options
          {
            refresh: generate_code
          }
        end
      end
    end
  end
end
