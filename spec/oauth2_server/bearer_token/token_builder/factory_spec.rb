require 'spec_helper'

describe Oauth2Server::BearerToken::TokenBuilder::Factory do
  subject(:factory) { described_class.new(client, request, options) }
  let(:client) { FactoryGirl.build(:client) }
  let(:request) { Rack::Request.new(env) }
  let(:options) { stub('options') }

  context 'when no grant_type param' do
    let(:env) { Rack::MockRequest.env_for('/') }

    specify { expect { factory.token_builder }.to raise_error(
      Oauth2Server::Errors::InvalidRequest, 'Missing grant_type') }
  end

  context 'when unsupported grant_type given' do
    let(:env) { Rack::MockRequest.env_for('/?grant_type=nonsense') }

    specify { expect { factory.token_builder }.to raise_error(
      Oauth2Server::Errors::UnsupportedGrantType) }
  end


  {
    client_credentials: 'ClientCredentials',
    password: 'Password',
    authorization_code: 'AuthorizationCode',
    refresh_token: 'RefreshToken'
  }.each do |grant_type, token_builder_type|
    context "when #{grant_type} grant_type given" do
      let(:env) { Rack::MockRequest.env_for("/?grant_type=#{grant_type}") }
      let(:token_builder) { stub(token_builder_type) }

      before do
        "Oauth2Server::BearerToken::TokenBuilder::#{token_builder_type}".constantize.stub(:new).
          with(client, request, options) { token_builder }
      end

      it "creates and returns a #{token_builder_type} token builder" do
        expect(factory.token_builder).to eql(token_builder)
      end
    end
  end
end
