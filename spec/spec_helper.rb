require 'rubygems'
require 'spork'

Spork.prefork do
  require 'factory_girl'
  FactoryGirl.find_definitions
  require 'rspec'
end

Spork.each_run do
  require 'oauth2_server'
end
