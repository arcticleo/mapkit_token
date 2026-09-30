require "active_support/all"
require "mapkit_token/version"
require "mapkit_token/config"
require "mapkit_token/app/models/mapkit.rb"
require "jwt"

module MapkitToken
  mattr_accessor :app_root
  mattr_accessor :auth_key
  mattr_accessor :auth_key_path
  mattr_accessor :auth_key_id
  mattr_accessor :apple_team_id

  def self.setup
    yield self
  end

  def self.config
    Config.new
  end
end

require "mapkit_token/engine"
