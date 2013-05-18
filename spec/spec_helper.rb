require 'rubygems'
require 'spork'
require 'rspec'

Spork.prefork do
end

Spork.each_run do
  require 'oauth2_server'
end
