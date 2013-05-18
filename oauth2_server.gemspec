require File.expand_path('../lib/oauth2_server/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'rack'

  gem.authors = %w(Michael England)
  gem.email = %w(mg.england@gmail.com)
  gem.summary = %q{Ruby OAuth2 Server Implementation}
  gem.description = %q{Modularised, extendable OAuth2 server implementation. Adheres to as many variants of the OAuth2 draft/client as possible.}
  gem.homepage = 'https://github.com/michaelengland/oauth2_server'

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.name = 'oauth2_server'
  gem.require_paths = %w(lib)
  gem.version = Oauth2Server::Version
end
