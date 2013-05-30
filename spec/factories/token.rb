require 'factory_girl'
require 'set'

FactoryGirl.define do
  trait :client_credentials do
    grant_type 'client_credentials'
    refresh 'UniqueRefresh'
  end

  trait :implicit_grant do
    resource_owner stub('ResourceOwner')
    grant_type 'implicit_grant'
  end

  trait :password do
    resource_owner stub('ResourceOwner')
    grant_type 'password'
    refresh 'UniqueRefresh'
  end

  trait :authorization_code do
    resource_owner stub('ResourceOwner')
    grant_type 'authorization_code'
    refresh 'UniqueRefresh'
  end

  factory :token, class: 'Oauth2Server::Entities::Token' do
    ignore do
      association :client, strategy: :build
      access 'UniqueAccess'
      resource_owner nil
      refresh nil
      scopes nil
    end

    client_credentials

    initialize_with { new(client, grant_type, access, {
      resource_owner: resource_owner,
      refresh: refresh,
      scopes: scopes
    }) }

    factory :client_credentials_token, :traits => [:client_credentials]
    factory :password_token, :traits => [:password]
    factory :authorization_code_token, :traits => [:authorization_code]
    factory :implicit_grant_token, :traits => [:implicit_grant]
  end
end
