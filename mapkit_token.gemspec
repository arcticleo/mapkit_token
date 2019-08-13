
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mapkit_token/version"

Gem::Specification.new do |spec|
  spec.name          = "mapkit_token"
  spec.version       = MapkitToken::VERSION
  spec.authors       = ["Michael Edlund"]
  spec.email         = ["medlund@mac.com"]

  spec.summary       = %q{MapKit JS token endpoint provider.}
  spec.homepage      = "https://github.com/arcticleo/mapkit_token"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
