module Oauth2Server
  module Entities
    class Client
      attr_reader :name, :uid, :secret

      def initialize(name, uid, secret, options = {})
        @name = name
        @uid = uid
        @secret = secret
        @options = options
      end

      def redirect_uri
        options[:redirect_uri]
      end
    end
  end
end
