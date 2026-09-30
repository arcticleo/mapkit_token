require "bundler/setup"
require "fileutils"
require "tmpdir"
require "mapkit_token"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.verify_partial_doubles = true
  end

  config.before do
    MapkitToken::Config::ENV_NAMES.each_value { |name| ENV.delete(name) }
    %i[app_root auth_key auth_key_path auth_key_id apple_team_id].each do |setting|
      MapkitToken.public_send("#{setting}=", nil)
    end
  end
end
