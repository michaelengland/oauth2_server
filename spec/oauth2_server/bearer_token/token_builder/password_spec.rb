require 'spec_helper'

describe Oauth2Server::BearerToken::TokenBuilder::Password do
  subject(:password) { described_class.new(client, request, options) }
  let(:client) { FactoryGirl.build(:client) }
  let(:request) { Rack::Request.new(env) }
  let(:resource_owner_repository) { stub('ResourceOwnerRepository') }
  let(:resource_owner) { stub('ResourceOwner') }

  before do
    resource_owner_repository.stub(:find_by_username_and_password).with('foo', 'bar') { resource_owner }
    resource_owner_repository.stub(:find_by_username_and_password).with('totally', 'wrong')
    SecureRandom.stub(:hex).with(10) { 'ABC123' }
  end

  shared_examples_for 'builds password tokens' do
    context 'when no username param' do
      let(:env) { Rack::MockRequest.env_for('/?password=bar') }

      specify { expect { password.token }.to raise_error(
        Oauth2Server::Errors::InvalidRequest, 'Missing username') }
    end

    context 'when no password param' do
      let(:env) { Rack::MockRequest.env_for('/?username=foo') }

      specify { expect { password.token }.to raise_error(
        Oauth2Server::Errors::InvalidRequest, 'Missing password') }
    end

    context 'when user login params info incorrect' do
      let(:env) { Rack::MockRequest.env_for('/?username=totally&password=wrong') }

      specify { expect { password.token }.to raise_error(
        Oauth2Server::Errors::InvalidGrant) }
    end

    context 'when user login params info correct' do
      let(:env) { Rack::MockRequest.env_for('/?username=foo&password=bar') }

      it 'sets the grant_type' do
        expect(password.token.grant_type).to eql('password')
      end

      it 'sets the client to that given' do
        expect(password.token.client).to eql(client)
      end

      it 'sets the access' do
        expect(password.token.access).to eql('ABC123')
      end

      it 'sets the refresh' do
        expect(password.token.refresh).to eql('ABC123')
      end

      it 'sets the resource_owner' do
        expect(password.token.resource_owner).to eql(resource_owner)
      end
    end
  end

  context 'when token_length and resource_owner_repository given' do
    let(:options) { {token_length: 10, resource_owner_repository: resource_owner_repository} }

    it_behaves_like 'builds password tokens'
  end

  context 'when token_length and an array of resource_owner repositories given' do
    let(:options) { {token_length: 10, resource_owner_repositories: [resource_owner_repository]} }

    it_behaves_like 'builds password tokens'
  end

  context 'when configuration given' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      configuration.register_resource_owner_repository(resource_owner_repository)
    end

    it_behaves_like 'builds password tokens'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      configuration.register_resource_owner_repository(resource_owner_repository)
      Oauth2Server.stub(:configuration) { configuration }
    end

    it_behaves_like 'builds password tokens'
  end
end
