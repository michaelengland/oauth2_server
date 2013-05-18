#!/usr/bin/env rake

require 'bundler/gem_helper'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks(name: 'oauth2_server')

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Default: run specs'
task default: :spec
