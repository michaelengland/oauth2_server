require 'spec_helper'

describe Oauth2Server::BearerToken::TokenBuilder::AuthorizationCode do
  subject(:authorization_code) { described_class.new(client, request, options) }
  let(:client) { FactoryGirl.build(:client) }
  let(:request) { Rack::Request.new(env) }
  let(:authorization_grant) { FactoryGirl.build(:authorization_grant,
    resource_owner: resource_owner,
    redirect_uri: 'client://login'
  ) }
  let(:resource_owner) { stub('ResourceOwner') }
  let(:authorization_grant_repository) { stub('AuthorizationGrantRepository') }

  before do
    authorization_grant_repository.stub(:find_by_client_and_code).with(client, 'foo') { authorization_grant }
    authorization_grant_repository.stub(:find_by_client_and_code).with(client, 'wrong')
    SecureRandom.stub(:hex).with(10) { 'ABC123' }
  end

  shared_examples_for 'successfully creates authorization_code tokens' do
    it 'sets the grant_type' do
      expect(authorization_code.token.grant_type).to eql('authorization_code')
    end

    it 'sets the client to that given' do
      expect(authorization_code.token.client).to eql(client)
    end

    it 'sets the access' do
      expect(authorization_code.token.access).to eql('ABC123')
    end

    it 'sets the refresh' do
      expect(authorization_code.token.refresh).to eql('ABC123')
    end

    it 'sets the resource_owner' do
      expect(authorization_code.token.resource_owner).to eql(resource_owner)
    end
  end

  shared_examples_for 'builds authorization_code tokens' do
    context 'when no code param' do
      let(:env) { Rack::MockRequest.env_for('/') }

      specify { expect { authorization_code.token }.to raise_error(
        Oauth2Server::Errors::InvalidRequest, 'Missing code') }
    end

    context 'when code incorrect' do
      let(:env) { Rack::MockRequest.env_for('/?code=wrong') }

      specify { expect { authorization_code.token }.to raise_error(
        Oauth2Server::Errors::InvalidGrant) }
    end

    context 'when retrieved authorization_grant has redirect_uri set' do
      context 'when redirect_uri param not given' do
        let(:env) { Rack::MockRequest.env_for('/?code=foo') }

        specify { expect { authorization_code.token }.to raise_error(
          Oauth2Server::Errors::InvalidRequest, 'Missing redirect_uri') }
      end

      context 'when redirect_uri param different to one set in retrieved authorization_grant' do
        let(:env) { Rack::MockRequest.env_for('/?code=foo&redirect_uri=client://login?foo=bar') }

        specify { expect { authorization_code.token }.to raise_error(
          Oauth2Server::Errors::InvalidGrant, 'Redirect uri does not match') }
      end

      context 'when redirect_uri param same as one set in retrieved authorization_grant' do
        let(:env) { Rack::MockRequest.env_for('/?code=foo&redirect_uri=client://login') }

        it_behaves_like 'successfully creates authorization_code tokens'
      end
    end

    context 'when retrieved authorization_grant has no redirect_uri set' do
      let(:env) { Rack::MockRequest.env_for('/?code=foo') }

      before do
        authorization_grant.stub(:redirect_uri) { nil }
      end

      it_behaves_like 'successfully creates authorization_code tokens'
    end
  end

  context 'when token_length and authorization grant repository given' do
    let(:options) { {token_length: 10, authorization_grant_repository: authorization_grant_repository} }

    it_behaves_like 'builds authorization_code tokens'
  end

  context 'when token_length and an array of authorization grant repositories given' do
    let(:options) { {token_length: 10, authorization_grant_repositories: [authorization_grant_repository]} }

    it_behaves_like 'builds authorization_code tokens'
  end

  context 'when configuration given' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      configuration.register_authorization_grant_repository(authorization_grant_repository)
    end

    it_behaves_like 'builds authorization_code tokens'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      configuration.register_authorization_grant_repository(authorization_grant_repository)
      Oauth2Server.stub(:configuration) { configuration }
    end

    it_behaves_like 'builds authorization_code tokens'
  end
end
