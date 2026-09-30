RSpec.describe MapkitToken do
  it "has a version number" do
    expect(MapkitToken::VERSION).not_to be nil
  end

  it "yields itself to an initializer" do
    MapkitToken.setup { |config| config.auth_key_id = "FROMSETUP" }

    expect(MapkitToken.auth_key_id).to eq "FROMSETUP"
  end
end
