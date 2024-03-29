lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dexcom_share_api/version"

Gem::Specification.new do |spec|
  spec.name          = "dexcom_share_api"
  spec.version       = DexcomShareApi::VERSION
  spec.authors       = ["Elliot Dohm"]
  spec.email         = ["elliotdohm+rubygems@gmail.com"]

  spec.summary       = "Tiny API layer for interacting with Dexcom Share API"
  spec.description   = "Tiny API layer for interacting with Dexcom Share API"
  spec.homepage      = "https://github.com/aud/dexcom_share_ruby"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "minitest", "~> 5.0"
end
