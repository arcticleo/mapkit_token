require "active_support/all"
require "mapkit_token/version"
require "mapkit_token/app/models/mapkit.rb"
require "jwt"

module MapkitToken
  mattr_accessor :app_root

  def self.setup
    yield self
  end
end

require "mapkit_token/engine"

