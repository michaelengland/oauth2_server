require 'spec_helper'

describe Oauth2Server::BearerToken::TokenBuilder::RefreshToken do
  subject(:refresh_token) { described_class.new(client, request, options) }
  let(:client) { FactoryGirl.build(:client) }
  let(:request) { Rack::Request.new(env) }
  let(:token_repository) { stub('TokenRepository') }
  let(:token) { FactoryGirl.build(:token, resource_owner: resource_owner) }
  let(:resource_owner) { stub('ResourceOwner') }

  before do
    token_repository.stub(:find_by_client_and_refresh).with(client, 'foo') { token }
    token_repository.stub(:find_by_client_and_refresh).with(client, 'wrong')
    SecureRandom.stub(:hex).with(10) { 'ABC123' }
  end

  shared_examples_for 'builds refresh_token tokens' do
    context 'when no refresh_token param' do
      let(:env) { Rack::MockRequest.env_for('/') }

      specify { expect { refresh_token.token }.to raise_error(
        Oauth2Server::Errors::InvalidRequest, 'Missing refresh_token') }
    end

    context 'when refresh_token param info incorrect' do
      let(:env) { Rack::MockRequest.env_for('/?refresh_token=wrong') }

      specify { expect { refresh_token.token }.to raise_error(
        Oauth2Server::Errors::InvalidGrant) }
    end

    context 'when refresh_token param info correct' do
      let(:env) { Rack::MockRequest.env_for('/?refresh_token=foo') }

      it 'sets the grant_type' do
        expect(refresh_token.token.grant_type).to eql('refresh_token')
      end

      it 'sets the client to that given' do
        expect(refresh_token.token.client).to eql(client)
      end

      it 'sets the access' do
        expect(refresh_token.token.access).to eql('ABC123')
      end

      it 'sets the refresh' do
        expect(refresh_token.token.refresh).to eql('ABC123')
      end

      it 'sets the resource_owner' do
        expect(refresh_token.token.resource_owner).to eql(resource_owner)
      end
    end
  end

  context 'when token_length and token_repository given' do
    let(:options) { {token_length: 10, token_repository: token_repository} }

    it_behaves_like 'builds refresh_token tokens'
  end

  context 'when token_length and an array of token repositories given' do
    let(:options) { {token_length: 10, token_repositories: [token_repository]} }

    it_behaves_like 'builds refresh_token tokens'
  end

  context 'when configuration given' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      configuration.register_token_repository(token_repository)
    end

    it_behaves_like 'builds refresh_token tokens'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      configuration.register_token_repository(token_repository)
      Oauth2Server.stub(:configuration) { configuration }
    end

    it_behaves_like 'builds refresh_token tokens'
  end
end
