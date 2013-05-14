module Oauth2Server
  module Version
    extend self

    MAJOR = 0 unless defined? MAJOR
    MINOR = 0 unless defined? MINOR
    PATCH = 1 unless defined? PATCH
    PRE = nil unless defined? PRE

    def to_s
      [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end
  end
end
