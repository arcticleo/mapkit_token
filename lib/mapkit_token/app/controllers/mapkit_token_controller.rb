class MapkitTokenController < ApplicationController

  def mapkit
    Rails.application.credentials.mapkit
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
#    render plain: Mapkit.token.generate(auth_key: auth_key, auth_key_id: auth_key_id, apple_team_id: apple_team_id, base_url: "https://new.bbs.dev.luxre.net")
    render plain: Mapkit.token.generate(auth_key: auth_key, auth_key_id: auth_key_id, apple_team_id: apple_team_id)
  end
end

