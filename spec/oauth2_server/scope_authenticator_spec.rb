require 'spec_helper'

describe Oauth2Server::ScopeAuthenticator do
  subject(:authenticator) { described_class.new(token) }
  let(:token) { Oauth2Server::Entities::Token.new(client, 'password', 'foobar', scopes: [:foo].to_set) }
  let(:client) { Oauth2Server::Entities::Client.new('Test Client', 'foo', 'bar') }

  describe '#authenticate_scope!' do
    context 'when scope given is not covered by the token' do
      specify { expect { authenticator.authenticate_scope!(:bar) }.to raise_error(
        Oauth2Server::Errors::InsufficientScope) }
    end

    context 'when scope given is covered by the token' do
      specify { expect(authenticator.authenticate_scope!(:foo)).to be_true }
    end
  end
end
