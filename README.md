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

Add your AuthKey to your application folder, and make sure you have these pieces of information:

- Path to AuthKey
- MapKit JS Key ID
- Apple Developer Team ID

Edit your application credentials:

    $ EDITOR=vim rails credentials:edit

In case you have different AuthKey files for your different environments, edit your environment credentials separately:

    $ EDITOR=vim rails credentials:edit --environment development

Add your credentials:

```yaml
mapkit:
  auth_key_path: AuthKey_XXXXXXXXXX.p8
  auth_key_id: XXXXXXXXXX
  apple_team_id: XXXXXXXXXX
```

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
