require 'rack'

module Oauth2Server
  class AuthorizationHeaderRetriever
    def initialize(request)
      @request = request
    end

    def authorization_header
      request.env['HTTP_AUTHORIZATION'] ||
        request.env['X-HTTP_AUTHORIZATION'] ||
        request.env['X_HTTP_AUTHORIZATION'] ||
        request.env['REDIRECT_X_HTTP_AUTHORIZATION']
    end

    private
    attr_reader :request
  end
end
