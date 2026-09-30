module MapkitToken
  class MapkitTokenController < ApplicationController

    def show
      render plain: Mapkit.token.generate(
        auth_key: mapkit.auth_key,
        auth_key_id: mapkit.auth_key_id,
        apple_team_id: mapkit.apple_team_id,
        base_url: base_url
      )
    end

    private

    def mapkit
      MapkitToken.config
    end

    def base_url
      request.protocol + request.host
    end
  end
end
