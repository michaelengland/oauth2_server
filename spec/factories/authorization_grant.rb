require 'factory_girl'

FactoryGirl.define do
  factory :authorization_grant, class: 'Oauth2Server::Entities::AuthorizationGrant' do
    ignore do
      association :client, strategy: :build
      resource_owner stub('ResourceOwner')
      code 'UniqueCode'
      redirect_uri 'client://login'
    end

    initialize_with { new(client, resource_owner, code, redirect_uri: redirect_uri) }
  end
end
