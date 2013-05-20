require 'oauth2_server/errors'
require 'oauth2_server/configuration'
require 'oauth2_server/entities'
require 'oauth2_server/authorization_header_retriever'
require 'oauth2_server/client_authenticator'
require 'oauth2_server/scope_authenticator'
require 'oauth2_server/bearer_token'

module Oauth2Server
  extend self

  def configure
    yield configuration
  end

  def configuration
    @_configuration ||= Configuration.new
  end
end
