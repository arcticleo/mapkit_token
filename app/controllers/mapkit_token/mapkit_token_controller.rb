module MapkitToken
  class MapkitTokenController < ApplicationController

    def mapkit
      if Rails.application.respond_to?(:credentials)
        Rails.application.credentials.mapkit
      else
        Rails.application.secrets.mapkit.symbolize_keys
      end
    end

    def auth_key
      File.read(mapkit[:auth_key_path])
    end

    def auth_key_id
      mapkit[:auth_key_id]
    end

    def apple_team_id
      mapkit[:apple_team_id]
    end

    def base_url
      request.protocol + request.host
    end

    def show
      render plain: Mapkit.token.generate(auth_key: auth_key, auth_key_id: auth_key_id, apple_team_id: apple_team_id, base_url: base_url)
    end
  end
end
