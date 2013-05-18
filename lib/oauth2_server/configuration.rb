module Oauth2Server
  class Configuration
    def registered_client_repositories
      @_registered_client_repositories ||= []
    end

    def register_client_repository(client_repository)
      registered_client_repositories << client_repository
    end
  end
end