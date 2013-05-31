require 'spec_helper'

describe Oauth2Server::BearerToken::Builder::ClientCredentials do
  subject(:client_credentials) { described_class.new(client, request, options) }
  let(:client) { FactoryGirl.build(:client) }
  let(:request) { stub('request') }

  before do
    SecureRandom.stub(:hex).with(10) { 'ABC123' }
  end

  shared_examples_for 'builds client_credentials tokens' do
    it 'sets the grant_type' do
      expect(client_credentials.token.grant_type).to eql('client_credentials')
    end

    it 'sets the client to that given' do
      expect(client_credentials.token.client).to eql(client)
    end

    it 'sets the access' do
      expect(client_credentials.token.access).to eql('ABC123')
    end

    it 'sets the refresh' do
      expect(client_credentials.token.refresh).to eql('ABC123')
    end

    it 'does not set the resource_owner' do
      expect(client_credentials.token.resource_owner).to be_nil
    end
  end

  context 'when token_length given' do
    let(:options) { {token_length: 10} }

    it_behaves_like 'builds client_credentials tokens'
  end

  context 'when configuration given' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
    end

    it_behaves_like 'builds client_credentials tokens'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.token_length = 10
      Oauth2Server.stub(:configuration) { configuration }
    end

    it_behaves_like 'builds client_credentials tokens'
  end
end
