require "pathname"

module MapkitToken
  class ConfigurationError < StandardError; end

  class Config
    ENV_NAMES = {
      :auth_key      => "MAPKIT_AUTH_KEY",
      :auth_key_path => "MAPKIT_AUTH_KEY_PATH",
      :auth_key_id   => "MAPKIT_AUTH_KEY_ID",
      :apple_team_id => "MAPKIT_APPLE_TEAM_ID"
    }.freeze

    PEM_MARKER = "-----BEGIN".freeze

    def auth_key
      carried = setting(:auth_key)
      return pem(carried) if carried.present?

      path = auth_key_path
      if path.blank?
        raise ConfigurationError, explain("No MapKit auth key. Set the contents " \
          "of the .p8 with #{places(:auth_key)}, or a path to it with " \
          "#{places(:auth_key_path)}.")
      end

      file = expand_path(path)
      unless File.exist?(file)
        raise ConfigurationError, "MapKit auth key file not found at #{file}"
      end
      pem(File.read(file))
    end

    def auth_key_path
      setting(:auth_key_path)
    end

    def auth_key_id
      require_setting(:auth_key_id, "No MapKit key id.")
    end

    def apple_team_id
      require_setting(:apple_team_id, "No Apple team id.")
    end

    def auth_key?
      auth_key
      true
    rescue ConfigurationError
      false
    end

    private

    def setting(name)
      from_initializer(name) || from_credentials(name) || from_env(name)
    end

    def require_setting(name, message)
      value = setting(name)
      if value.blank?
        raise ConfigurationError, explain("#{message} Set it with #{places(name)}.")
      end
      value
    end

    def places(name)
      "config.#{name} in MapkitToken.setup, `mapkit: #{name}` in the " \
        "credentials, or #{ENV_NAMES.fetch(name)}"
    end

    # A credentials file that can't be decrypted reads as empty, so the
    # environment still gets its turn; say so when nothing is found there.
    def explain(message)
      return message if @credentials_error.nil?
      "#{message} The credentials could not be read " \
        "(#{@credentials_error.class}), so any MapKit settings in them were skipped."
    end

    def from_initializer(name)
      MapkitToken.public_send(name).presence
    end

    def from_credentials(name)
      credentials[name].presence
    end

    def from_env(name)
      ENV[ENV_NAMES.fetch(name)].presence
    end

    def credentials
      store = credentials_store
      return {} if store.nil?
      store.respond_to?(:to_h) ? store.to_h.symbolize_keys : {}
    rescue StandardError => e
      @credentials_error = e
      {}
    end

    def credentials_store
      app = application
      return nil if app.nil?

      if app.respond_to?(:credentials)
        app.credentials.mapkit
      elsif app.respond_to?(:secrets)
        app.secrets.mapkit
      end
    end

    def application
      return nil unless defined?(Rails) && Rails.respond_to?(:application)
      Rails.application
    end

    def app_root
      MapkitToken.app_root || (application && Rails.root) || Dir.pwd
    end

    def expand_path(path)
      pathname = Pathname.new(path.to_s)
      pathname.absolute? ? pathname.to_s : File.join(app_root.to_s, pathname.to_s)
    end

    def pem(value)
      key = value.to_s.strip.gsub('\n', "\n")
      return terminate(key) if key.include?(PEM_MARKER)

      decoded = key.unpack1("m").force_encoding(Encoding::UTF_8)
      decoded.include?(PEM_MARKER) ? terminate(decoded) : key
    end

    def terminate(key)
      key.end_with?("\n") ? key : key + "\n"
    end
  end
end
