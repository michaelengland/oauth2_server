require 'set'

module Oauth2Server
  module Entities
    class AuthorizationGrant
      attr_reader :client, :resource_owner, :code

      def initialize(client, resource_owner, code, options = {})
        @client = client
        @resource_owner = resource_owner
        @code = code
        @options = options
      end

      def redirect_uri
        options[:redirect_uri]
      end

      def scopes
        options[:scopes] || Set.new
      end

      private
      attr_reader :options
    end
  end
end
