require 'factory_girl'

FactoryGirl.define do
  factory :client, class: 'Oauth2Server::Entities::Client' do
    ignore do
      name 'TestClient'
      uid 'UniqueID'
      secret 'UniqueSecret'
      redirect_uri 'client://login'
    end

    initialize_with { new(name, uid, secret, redirect_uri: redirect_uri) }
  end
end
