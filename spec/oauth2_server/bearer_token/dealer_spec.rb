require 'spec_helper'

describe Oauth2Server::BearerToken::Dealer do
  subject(:dealer) { described_class.new(request, options) }
  let(:request) { Rack::Request.new(env) }
  let(:env) { Rack::MockRequest.env_for('/') }
  let(:client_authenticator) { stub('ClientAuthenticator', client: client) }
  let(:client) { FactoryGirl.build(:client) }
  let(:builder_factory) { stub('BuilderFactory', builder: builder) }
  let(:builder) { stub('Builder', token: token) }
  let(:token) { FactoryGirl.build(:token) }
  let(:token_repository) { stub('TokenRepository') }

  before do
    Oauth2Server::ClientAuthenticator.stub(:new).
      with(request, options) { client_authenticator }
    Oauth2Server::BearerToken::Builder::Factory.stub(:new).
      with(client, request, options) { builder_factory }
    token_repository.stub(:save_token).with(token)
  end

  shared_examples_for 'deals tokens' do
    [:deal!, :token].each do |method|
      describe "##{method}" do
        it 'saves created token to repository' do
          token_repository.should_receive(:save_token).with(token)
          dealer.public_send(method)
        end

        it 'returns created token' do
          expect(dealer.public_send(method)).to eql(token)
        end
      end
    end
  end

  context 'when token_repository given' do
    let(:options) { {token_repository: token_repository} }

    it_behaves_like 'deals tokens'
  end

  context 'when an array of token repositories given' do
    let(:options) { {token_repositories: [token_repository]} }

    it_behaves_like 'deals tokens'
  end

  context 'when configuration given' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.register_token_repository(token_repository)
    end

    it_behaves_like 'deals tokens'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.register_token_repository(token_repository)
      Oauth2Server.stub(:configuration) { configuration }
    end

    it_behaves_like 'deals tokens'
  end
end
