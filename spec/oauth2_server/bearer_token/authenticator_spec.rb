require 'spec_helper'

describe Oauth2Server::BearerToken::Authenticator do
  subject(:authenticator) { described_class.new(request, options) }
  let(:request) { Rack::Request.new(env) }
  let(:token) { Oauth2Server::Entities::Token.new(client, 'password', 'foobar') }
  let(:client) { Oauth2Server::Entities::Client.new('Test Client', 'foo', 'bar') }
  let(:token_repository) { stub('TokenRepository') }
  let(:retriever) { stub('Retriever', authorization_header: nil) }

  before do
    Oauth2Server::AuthorizationHeaderRetriever.stub(:new).with(request).and_return(retriever)
    token_repository.stub(:find_token_by_access).with('foobar').and_return(token)
    token_repository.stub(:find_token_by_access).with('totallywrong')
  end

  shared_examples_for 'authenticates bearer tokens' do
    [:authenticate!, :token].each do |method|
      context 'when authorization header set with non-bearer token' do
        let(:env) { Rack::MockRequest.env_for('/') }

        before do
          retriever.stub(:authorization_header).and_return('Absolute nonsense')
        end

        specify { expect { authenticator.public_send(method) }.to raise_error(Oauth2Server::Errors::TokenMissing) }
      end

      %w(Bearer OAuth).each do |auth_prefix|
        context "when authorization header set to genuine Bearer token with #{auth_prefix} prefix" do
          let(:env) { Rack::MockRequest.env_for('/') }

          before do
            retriever.stub(:authorization_header).and_return("#{auth_prefix} foobar")
          end

          it 'returns successfully retrieved token' do
            expect(authenticator.public_send(method)).to eql(token)
          end
        end

        context 'when authorization header set to incorrect info' do
          let(:env) { Rack::MockRequest.env_for('/') }

          before do
            retriever.stub(:authorization_header).and_return("#{auth_prefix} totallywrong")
          end

          specify { expect { authenticator.public_send(method) }.to raise_error(Oauth2Server::Errors::InvalidToken) }
        end
      end

      context 'when oauth_token parameter set to genuine Bearer token' do
        let(:env) { Rack::MockRequest.env_for('/?oauth_token=foobar') }

        it 'returns successfully retrieved token' do
          expect(authenticator.public_send(method)).to eql(token)
        end
      end

      context 'when access_token parameter set to genuine Bearer token' do
        let(:env) { Rack::MockRequest.env_for('/?access_token=foobar') }

        it 'returns successfully retrieved token' do
          expect(authenticator.public_send(method)).to eql(token)
        end
      end

      context 'when bearer token missing' do
        let(:env) { Rack::MockRequest.env_for('/') }

        specify { expect { authenticator.public_send(method) }.to raise_error(Oauth2Server::Errors::TokenMissing) }
      end

      context 'when oauth_token parameter set to incorrect info' do
        let(:env) { Rack::MockRequest.env_for('/?oauth_token=totallywrong') }

        specify { expect { authenticator.public_send(method) }.to raise_error(Oauth2Server::Errors::InvalidToken) }
      end

      context 'when access_token parameter set to incorrect info' do
        let(:env) { Rack::MockRequest.env_for('/?access_token=totallywrong') }

        specify { expect { authenticator.public_send(method) }.to raise_error(Oauth2Server::Errors::InvalidToken) }
      end
    end
  end

  context 'when given a token repository' do
    let(:options) { {token_repository: token_repository} }

    it_behaves_like 'authenticates bearer tokens'
  end

  context 'when given an array of token repositories' do
    let(:options) { {token_repositories: [token_repository]} }

    it_behaves_like 'authenticates bearer tokens'
  end

  context 'when given a configuration' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.register_token_repository(token_repository)
    end

    it_behaves_like 'authenticates bearer tokens'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.register_token_repository(token_repository)
      Oauth2Server.stub(:configuration).and_return(configuration)
    end

    it_behaves_like 'authenticates bearer tokens'
  end
end
