require 'spec_helper'

describe Oauth2Server::BearerToken::AuthenticationHeaderBuilder do
  subject(:builder) { described_class.new(options) }

  shared_examples_for 'builds authentication headers' do
    context 'when missing token error' do
      let(:error) { Oauth2Server::Errors::TokenMissing.new }

      it 'should include only the realm in the header' do
        expect(builder.header(error)).to eql('Bearer realm="Test Realm"')
      end
    end

    context 'when error includes type' do
      let(:error) { Oauth2Server::Errors::InvalidToken.new }

      it 'should include the realm & type in the header' do
        expect(builder.header(error)).to eql('Bearer realm="Test Realm", error="invalid_token"')
      end
    end

    context 'when error includes description' do
      let(:error) { Oauth2Server::Errors::InvalidToken.new(description: 'The access token was revoked') }

      it 'should include the realm, type & description in the header' do
        expect(builder.header(error)).to eql(
          'Bearer realm="Test Realm", error="invalid_token", error_description="The access token was revoked"')
      end
    end

    context 'when insufficient scope error' do
      let(:error) { Oauth2Server::Errors::InsufficientScope.new(:write) }

      it 'should include the realm, scope, type & description in the header' do
        expect(builder.header(error)).to eql(
          'Bearer realm="Test Realm", scope="write", error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token"')
      end
    end
  end

  context 'when scope given' do
    let(:options) { {realm: 'Test Realm'} }

    it_behaves_like 'builds authentication headers'
  end

  context 'when configuration given' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.realm = 'Test Realm'
    end

    it_behaves_like 'builds authentication headers'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.realm = 'Test Realm'
      Oauth2Server.stub(:configuration).and_return(configuration)
    end

    it_behaves_like 'builds authentication headers'
  end
end
