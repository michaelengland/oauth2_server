require 'spec_helper'

describe Oauth2Server::ClientAuthenticator do
  subject(:authenticator) { described_class.new(request, options) }
  let(:request) { Rack::Request.new(env) }
  let(:client) { FactoryGirl.build(:client) }
  let(:client_repository) { stub('ClientRepository') }
  let(:retriever) { stub('Retriever', authorization_header: nil) }

  before do
    Oauth2Server::AuthorizationHeaderRetriever.stub(:new).with(request).and_return(retriever)
    client_repository.stub(:find_client_by_id_and_secret).with('foo', 'bar').and_return(client)
    client_repository.stub(:find_client_by_id_and_secret).with('totally', 'wrong')
  end

  shared_examples_for 'authenticates clients' do
    [:authenticate!, :client].each do |method|
      describe "##{method}" do
        context 'when no authorization header or client params set' do
          let(:env) { Rack::MockRequest.env_for('/') }

          specify { expect { subject.public_send(method) }.to raise_error(
            Oauth2Server::Errors::InvalidClient,
            'You must encode your client_id and client_secret either as parameters, or preferably using Basic HTTP Auth'
          ) }
        end

        context 'when client_id param set and client_secret param not set' do
          let(:env) { Rack::MockRequest.env_for('/?client_id=foo') }

          specify { expect { subject.public_send(method) }.to raise_error(
            Oauth2Server::Errors::InvalidClient,
            'You must provide both client_id and client_secret'
          ) }
        end

        context 'when client_secret param set and client_id param not set' do
          let(:env) { Rack::MockRequest.env_for('/?client_secret=bar') }

          specify { expect { subject.public_send(method) }.to raise_error(
            Oauth2Server::Errors::InvalidClient,
            'You must provide both client_id and client_secret'
          ) }
        end

        context 'when client_id and client_secret params set with incorrect info' do
          let(:env) { Rack::MockRequest.env_for('/?client_id=totally&client_secret=wrong') }

          specify { expect { subject.public_send(method) }.to raise_error(
            Oauth2Server::Errors::InvalidClient,
            'Your client credentials did not match'
          ) }
        end

        context 'when client_id and client_secret params set with correct info' do
          let(:env) { Rack::MockRequest.env_for('/?client_id=foo&client_secret=bar') }

          it 'returns successfully retrieved client' do
            expect(authenticator.public_send(method)).to eql(client)
          end
        end

        context 'when authorization header set with incorrect info' do
          let(:env) { Rack::MockRequest.env_for('/') }

          before do
            retriever.stub(:authorization_header).and_return('Basic dG90YWxseTp3cm9uZw==')
          end

          specify { expect { subject.public_send(method) }.to raise_error(
            Oauth2Server::Errors::InvalidClient,
            'Your client credentials did not match'
          ) }
        end

        context 'when authorization header not set with basic auth' do
          let(:env) { Rack::MockRequest.env_for('/') }

          before do
            retriever.stub(:authorization_header).and_return('Absolute nonsense')
          end

          specify { expect { subject.public_send(method) }.to raise_error(
            Oauth2Server::Errors::InvalidClient,
            'Your client credentials did not match'
          ) }
        end

        context 'when authorization header set with correct info' do
          let(:env) { Rack::MockRequest.env_for('/') }

          before do
            retriever.stub(:authorization_header).and_return('Basic Zm9vOmJhcg==')
          end

          it 'returns successfully retrieved client' do
            expect(authenticator.public_send(method)).to eql(client)
          end
        end
      end
    end
  end

  context 'when given a client repository' do
    let(:options) { {client_repository: client_repository} }

    it_behaves_like 'authenticates clients'
  end

  context 'when given an array of client repositories' do
    let(:options) { {client_repositories: [client_repository]} }

    it_behaves_like 'authenticates clients'
  end

  context 'when given a configuration' do
    let(:options) { {configuration: configuration} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.register_client_repository(client_repository)
    end

    it_behaves_like 'authenticates clients'
  end

  context 'when given no configuration' do
    let(:options) { {} }
    let(:configuration) { Oauth2Server::Configuration.new }

    before do
      configuration.register_client_repository(client_repository)
      Oauth2Server.stub(:configuration).and_return(configuration)
    end

    it_behaves_like 'authenticates clients'
  end
end
