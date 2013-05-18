require 'rack'
require 'active_support/core_ext/object/blank'
require 'base64'

module Oauth2Server
  class ClientAuthenticator
    def initialize(request, options = {})
      @request = request
      @options = options
    end

    def client
      @client ||= begin
        if authorization_header.present?
          client_from_header
        else
          client_from_params
        end
      end
    end

    alias_method :authenticate!, :client

    private
    attr_reader :request, :options

    def client_from_params
      if client_id_param.blank? && client_secret_param.blank?
        raise_missing_client_error
      elsif client_id_param.blank? || client_secret_param.blank?
        raise_missing_params_error
      else
        client_for_id_and_secret(client_id_param, client_secret_param)
      end
    end

    def client_from_header
      id, secret = client_info_from_header
      if id.present? && secret.present?
        client_for_id_and_secret(id, secret)
      else
        raise_invalid_info_error
      end
    end

    def client_id_param
      request.params['client_id']
    end

    def client_secret_param
      request.params['client_secret']
    end

    def authorization_header
      request.env['HTTP_AUTHORIZATION'] ||
        request.env['X-HTTP_AUTHORIZATION'] ||
        request.env['X_HTTP_AUTHORIZATION'] ||
        request.env['REDIRECT_X_HTTP_AUTHORIZATION']
    end

    def client_info_from_header
      if basic_encoded_info.present?
        Base64.decode64(basic_encoded_info).split(':')
      end
    end

    def basic_encoded_info
      @_basic_encoded_info ||= authorization_header.slice(%r{Basic (.*)}, 1)
    end

    def client_for_id_and_secret(id, secret)
      client_repositories.inject(nil) { |client, repository|
        client || repository.find_client_by_id_and_secret(id, secret)
      } || raise_invalid_info_error
    end

    def client_repositories
      @_client_repositories ||= begin
        if options.has_key?(:client_repository)
          Array(options[:client_repository])
        elsif options.has_key?(:client_repositories)
          options[:client_repositories]
        elsif options.has_key?(:configuration)
          options[:configuration].registered_client_repositories
        else
          Oauth2Server.configuration.registered_client_repositories
        end
      end
    end

    def raise_missing_client_error
      raise_error(
        'You must encode your client_id and client_secret either as parameters, or preferably using Basic HTTP Auth'
      )
    end

    def raise_missing_params_error
      raise_error('You must provide both client_id and client_secret')
    end

    def raise_invalid_info_error
      raise_error('Your client credentials did not match')
    end

    def raise_error(description)
      raise Errors::InvalidClient.new(description: description)
    end
  end
end
