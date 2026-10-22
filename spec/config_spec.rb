require "openssl"

RSpec.describe MapkitToken::Config do
  let(:key) { OpenSSL::PKey::EC.generate("prime256v1").to_pem }

  def stub_rails(mapkit, root: tmp_root)
    credentials = double("credentials", mapkit: mapkit)
    application = double("application", credentials: credentials)
    stub_const("Rails", double("Rails", application: application, root: root))
  end

  let(:tmp_root) { Dir.mktmpdir }

  def write_key(name = "AuthKey_ABCDEF1234.p8", contents = key)
    File.write(File.join(tmp_root, name), contents)
    name
  end

  after do
    FileUtils.remove_entry(tmp_root) if File.directory?(tmp_root)
  end

  describe "the key as a file" do
    it "is read from the path the credentials name, under the application root" do
      stub_rails({ auth_key_path: write_key })

      expect(subject.auth_key).to eq key
    end

    it "is read from the path the environment names" do
      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY_PATH"] = File.join(tmp_root, write_key)

      expect(subject.auth_key).to eq key
    end

    it "is read from an absolute path as it stands" do
      path = File.join(tmp_root, write_key)
      stub_rails({ auth_key_path: path }, root: "/nowhere")

      expect(subject.auth_key).to eq key
    end

    it "says where it looked when the file is not there" do
      stub_rails({ auth_key_path: "AuthKey_MISSING.p8" })

      expect { subject.auth_key }
        .to raise_error(MapkitToken::ConfigurationError, /AuthKey_MISSING\.p8/)
    end
  end

  describe "the key as contents" do
    it "is taken from the credentials" do
      stub_rails({ auth_key: key })

      expect(subject.auth_key).to eq key
    end

    it "is taken from the environment" do
      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY"] = key

      expect(subject.auth_key).to eq key
    end

    it "is taken from an initializer" do
      stub_rails(nil)
      MapkitToken.auth_key = key

      expect(subject.auth_key).to eq key
    end

    it "puts back newlines written as an escape" do
      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY"] = key.gsub("\n", '\n')

      expect(subject.auth_key).to eq key
    end

    it "decodes a key given as base64" do
      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY"] = [key].pack("m")

      expect(subject.auth_key).to eq key
    end

    it "is still a PEM OpenSSL will take" do
      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY"] = [key].pack("m")

      expect { OpenSSL::PKey::EC.new(subject.auth_key) }.not_to raise_error
    end
  end

  describe "the shape of what comes back" do
    let(:unterminated) { key.strip }

    it "terminates a file that ends without a newline" do
      stub_rails({ auth_key_path: write_key("AuthKey_ABCDEF1234.p8", unterminated) })

      expect(subject.auth_key).to eq "#{unterminated}\n"
    end

    it "answers the same for the file and for its contents in the environment" do
      stub_rails({ auth_key_path: write_key("AuthKey_ABCDEF1234.p8", unterminated) })
      from_file = subject.auth_key

      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY"] = [unterminated].pack("m")

      expect(subject.auth_key).to eq from_file
    end
  end

  describe "the order between them" do
    it "prefers what an initializer set to either" do
      stub_rails({ auth_key: "from credentials" })
      ENV["MAPKIT_AUTH_KEY"] = "from the environment"
      MapkitToken.auth_key = "from the initializer"

      expect(subject.auth_key).to eq "from the initializer"
    end

    it "prefers the credentials to the environment" do
      stub_rails({ auth_key: "from credentials" })
      ENV["MAPKIT_AUTH_KEY"] = "from the environment"

      expect(subject.auth_key).to eq "from credentials"
    end

    it "prefers contents anywhere to a path anywhere" do
      stub_rails({ auth_key_path: write_key })
      ENV["MAPKIT_AUTH_KEY"] = key.sub("PRIVATE", "PRIVATE ")

      expect(subject.auth_key).to eq key.sub("PRIVATE", "PRIVATE ")
    end
  end

  describe "the ids" do
    it "are read from the credentials" do
      stub_rails({ auth_key_id: "KEYFROMCREDS", apple_team_id: "TEAMFROMCREDS" })

      expect(subject.auth_key_id).to eq "KEYFROMCREDS"
      expect(subject.apple_team_id).to eq "TEAMFROMCREDS"
    end

    it "are read from the environment" do
      stub_rails(nil)
      ENV["MAPKIT_AUTH_KEY_ID"] = "KEYFROMENV"
      ENV["MAPKIT_APPLE_TEAM_ID"] = "TEAMFROMENV"

      expect(subject.auth_key_id).to eq "KEYFROMENV"
      expect(subject.apple_team_id).to eq "TEAMFROMENV"
    end

    it "say what is missing when they are nowhere" do
      stub_rails(nil)

      expect { subject.auth_key_id }
        .to raise_error(MapkitToken::ConfigurationError, /MAPKIT_AUTH_KEY_ID/)
      expect { subject.apple_team_id }
        .to raise_error(MapkitToken::ConfigurationError, /MAPKIT_APPLE_TEAM_ID/)
    end
  end

  describe "an application with none of it" do
    it "says every place it looked for the key" do
      stub_rails(nil)

      expect { subject.auth_key }.to raise_error(MapkitToken::ConfigurationError) { |error|
        expect(error.message).to include(
          "config.auth_key in MapkitToken.setup", "`mapkit: auth_key`", "MAPKIT_AUTH_KEY",
          "config.auth_key_path in MapkitToken.setup", "`mapkit: auth_key_path`", "MAPKIT_AUTH_KEY_PATH"
        )
      }
    end

    it "answers auth_key? rather than raising" do
      stub_rails(nil)

      expect(subject.auth_key?).to be false
    end

    it "reads the environment when the credentials cannot be read" do
      credentials = double("credentials")
      allow(credentials).to receive(:mapkit).and_raise(ActiveSupport::MessageEncryptor::InvalidMessage)
      application = double("application", credentials: credentials)
      stub_const("Rails", double("Rails", application: application, root: tmp_root))
      ENV["MAPKIT_AUTH_KEY"] = key

      expect(subject.auth_key).to eq key
    end

    it "says the credentials could not be read when the key is nowhere else" do
      credentials = double("credentials")
      allow(credentials).to receive(:mapkit).and_raise(ActiveSupport::MessageEncryptor::InvalidMessage)
      application = double("application", credentials: credentials)
      stub_const("Rails", double("Rails", application: application, root: tmp_root))

      expect { subject.auth_key }.to raise_error(
        MapkitToken::ConfigurationError, /credentials could not be read \(ActiveSupport::MessageEncryptor::InvalidMessage\)/
      )
      expect { subject.auth_key_id }.to raise_error(
        MapkitToken::ConfigurationError, /credentials could not be read/
      )
    end
  end

  describe "an application with secrets rather than credentials" do
    it "reads the mapkit section of them" do
      secrets = double("secrets", mapkit: { "auth_key" => key, "auth_key_id" => "OLDKEYID" })
      application = double("application", secrets: secrets)
      stub_const("Rails", double("Rails", application: application, root: tmp_root))

      expect(subject.auth_key).to eq key
      expect(subject.auth_key_id).to eq "OLDKEYID"
    end
  end

  describe "no Rails at all" do
    it "reads the environment, against the working directory" do
      ENV["MAPKIT_AUTH_KEY_PATH"] = File.join(tmp_root, write_key)

      expect(subject.auth_key).to eq key
    end
  end
end
