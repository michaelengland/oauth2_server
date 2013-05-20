module Oauth2Server
  class ScopeAuthenticator
    def initialize(token)
      @token = token
    end

    def authenticate_scope!(scope)
      unless token.scopes.include?(scope)
        raise Errors::InsufficientScope.new(scope: scope)
      end
      true
    end

    private
    attr_reader :token
  end
end
