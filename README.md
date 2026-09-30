# MapKit Token

MapKit JS uses JSON Web Tokens (JWTs) to authenticate map initializations and other API requests. This gem adds an endpoint to a Rails applications to provide MapKit JS with such authentication JWTs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mapkit_token'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mapkit_token

## Usage

Before you can use this gem, you need a Maps Identifer (i.e., Maps ID) and private key that is associated to a Maps ID. If you haven't yet done that, read more about how to do that here:

[Creating a Maps Identifier and a Private Key](https://developer.apple.com/documentation/mapkitjs/creating_a_maps_identifier_and_a_private_key)

You need three pieces of information: the private key, the MapKit JS Key ID, and your Apple Developer Team ID.

You can store them in an initializer, in your Rails credentials, or in environment variables. Use whichever fits the machine your application runs on. The gem checks those places in that order for each setting.

The key itself can be given either as the contents of the `.p8` file or as a path to it. The gem looks for the contents in all three places before it looks for a path. This means that if a server sets the key contents in its environment, that value is used even when the credentials point to a file that doesn't exist on that server.

### Option 1: Path to the key file in credentials

Add the `.p8` file from Apple to your application folder, then edit your credentials:

    $ EDITOR=vim rails credentials:edit

```yaml
mapkit:
  auth_key_path: AuthKey_XXXXXXXXXX.p8
  auth_key_id: XXXXXXXXXX
  apple_team_id: XXXXXXXXXX
```

A relative path is resolved from `Rails.root`. An absolute path is used as is. If you have different AuthKey files for different environments, edit each environment's credentials separately:

    $ EDITOR=vim rails credentials:edit --environment development

The gem provides legacy support for Rails secrets, so if your app uses Rails 4.1 through 5.1, you can store the same information in `/config/secrets.yml` and it will just work.

### Option 2: Key contents in credentials

If shipping the `.p8` file is inconvenient (for example, in a container image or on a server built only from the repository), you can paste the contents of the file into your credentials instead:

```yaml
mapkit:
  auth_key: |
    -----BEGIN PRIVATE KEY-----
    MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
    -----END PRIVATE KEY-----
  auth_key_id: XXXXXXXXXX
  apple_team_id: XXXXXXXXXX
```

### Option 3: Environment variables

You can also set everything with environment variables. This works well for deployments that keep secrets outside the repository:

```sh
MAPKIT_AUTH_KEY_ID=XXXXXXXXXX
MAPKIT_APPLE_TEAM_ID=XXXXXXXXXX

# Either the contents of the .p8 file...
MAPKIT_AUTH_KEY="$(cat AuthKey_XXXXXXXXXX.p8)"

# ...or the path to it, if the file is on the machine
MAPKIT_AUTH_KEY_PATH=/etc/mapkit/AuthKey_XXXXXXXXXX.p8
```

The key spans several lines, and some tools can't set an environment variable that contains newlines. For those cases, `MAPKIT_AUTH_KEY` also accepts two single-line formats:

- The key with each newline written as `\n`
- The whole file encoded as base64 (`base64 -w0 AuthKey_XXXXXXXXXX.p8`)

### Option 4: An initializer

If you'd rather configure the gem in code (for example, to read the key from a secrets manager or from environment variables with your own names), create `config/initializers/mapkit_token.rb`:

```ruby
MapkitToken.setup do |config|
  config.auth_key = Vault.read("mapkit").data[:p8]
  config.auth_key_id = ENV.fetch("MY_MAPKIT_KEY_ID")
  config.apple_team_id = ENV.fetch("MY_APPLE_TEAM_ID")
end
```

You can also set `config.app_root` here to resolve a relative `auth_key_path` from a folder other than `Rails.root`.

### Missing settings

If a setting can't be found, the gem raises `MapkitToken::ConfigurationError` with a message that says what's missing and where you can set it. You get this clear error instead of a confusing failure later on from an unreadable key.

To check whether a key is configured without raising an error, call `MapkitToken.config.auth_key?`. This is useful if you want to skip rendering a map when no token is available.

After reloading your application, it will have a new endpoint `/mapkit_token` that returns JWTs that are valid for 30 minutes. The application's hostname is added to the JWT payload to specify that the tokens only can used by the application itself.

Use the endpoint for the `authorizationCallback` function that MapKit JS calls whenever it detects that a new token is needed.

```html
<!DOCTYPE html>
<html>
...
<div id="map" style="width: 800px; height: 600px;"></div>
<script src="https://cdn.apple-mapkit.com/mk/5.0.x/mapkit.js"></script>
<script>
mapkit.init({ authorizationCallback: function(done) { fetch("/mapkit_token")
    .then(res => res.text())
    .then(token => done(token)) /* If successful, return your token to MapKit JS */ 
    .catch(error => { /* Handle error */ });
}});
let map = new mapkit.Map("map", { center: new mapkit.Coordinate(59.329, 18.068) }); 
</script>
...
</html>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mapkit_token. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the MapkitToken project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mapkit_token/blob/master/CODE_OF_CONDUCT.md).
