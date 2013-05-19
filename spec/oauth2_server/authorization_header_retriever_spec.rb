require 'spec_helper'

describe Oauth2Server::AuthorizationHeaderRetriever do
  subject(:retriever) { described_class.new(request) }
  let(:request) { Rack::Request.new(env) }
  let(:env) { Rack::MockRequest.env_for('/') }

  context 'when no authorization header set' do
    its(:authorization_header) { should be_nil }
  end

  %w(
    HTTP_AUTHORIZATION
    X-HTTP_AUTHORIZATION
    X_HTTP_AUTHORIZATION
    REDIRECT_X_HTTP_AUTHORIZATION
  ).each do |auth_header|
    context "when #{auth_header} header set to foobar" do
      before do
        env[auth_header] = 'foobar'
      end

      its(:authorization_header) { should eql('foobar') }
    end
  end
end
