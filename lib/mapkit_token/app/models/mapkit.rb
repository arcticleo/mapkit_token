class Mapkit
  @@instance = Mapkit.new
  private_class_method :new

  def self.token
    return @@instance
  end

  def generate *args
    return nil unless (creds = args.first).is_a?(Hash)

    auth_key = creds[:auth_key]
    auth_key_id = creds[:auth_key_id]
    apple_team_id = creds[:apple_team_id]
    base_url = creds[:base_url]
    lifespan_seconds = creds[:lifespan] ||= 1800

    header = {kid: auth_key_id, typ: "JWT", alg: "ES256"}
    payload = {iss: apple_team_id, iat: DateTime.now.to_i, exp: DateTime.now.to_i + lifespan_seconds, origin: base_url}.compact
    private_key = OpenSSL::PKey::EC.new(auth_key)
    return JWT.encode payload, private_key, algorithm='ES256', header
  end
end


