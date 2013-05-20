module Oauth2Server
  module Entities
    class Token
      attr_reader :client, :grant_type, :access

      def initialize(client, grant_type, access, options = {})
        @client = client
        @grant_type = grant_type
        @access = access
        @options = options
      end

      def resource_owner
        options[:resource_owner]
      end

      def refresh
        options[:refresh]
      end

      def scopes
        options[:scopes] || Set.new
      end

      private
      attr_reader :options
    end
  end
end
