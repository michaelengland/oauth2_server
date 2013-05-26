require 'spec_helper'
require 'set'

describe Oauth2Server::ScopeAuthenticator do
  subject(:authenticator) { described_class.new(token) }
  let(:token) { FactoryGirl.build(:token, scopes: [:foo].to_set) }

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
