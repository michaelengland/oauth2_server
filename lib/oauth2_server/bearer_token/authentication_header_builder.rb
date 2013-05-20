require 'active_support/core_ext/object/blank'

module Oauth2Server
  module BearerToken
    class AuthenticationHeaderBuilder
      def initialize(options = {})
        @options = options
      end

      def header(error)
        "Bearer #{extras(error).map { |k, v| "#{k}=\"#{v}\"" }.join(', ')}"
      end

      private
      attr_reader :options

      def extras(error)
        realm_extra.
          merge(scope_extra(error)).
          merge(error_extra(error)).
          merge(error_description_extra(error))
      end

      def realm_extra
        {realm: realm}
      end

      def scope_extra(error)
        include_scope_extra?(error) ? {scope: error.scope} : {}
      end

      def error_extra(error)
        include_error_extra?(error) ? {error: error.type} : {}
      end

      def error_description_extra(error)
        include_error_description_extra?(error) ? {error_description: error.description} : {}
      end

      def realm
        if options.has_key?(:realm)
          options[:realm]
        elsif options.has_key?(:configuration)
          options[:configuration].realm
        else
          Oauth2Server.configuration.realm
        end
      end

      def include_scope_extra?(error)
        error.is_a?(Errors::InsufficientScope) && error.scope.present?
      end

      def include_error_extra?(error)
        !error.is_a?(Errors::TokenMissing) && error.type.present?
      end

      def include_error_description_extra?(error)
        !error.is_a?(Errors::TokenMissing) && error.description.present?
      end
    end
  end
end
