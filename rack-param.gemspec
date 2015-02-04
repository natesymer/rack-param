# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "rack-param"
  spec.version       = "0.1.5"
  spec.authors       = ["Nathaniel Symer"]
  spec.email         = ["nate@natesymer.com"]
  spec.summary       = "Sane parameter validation for Rack::Request."
  spec.description   = spec.summary + " Originally written for use with Sansom."
  spec.homepage      = "https://github.com/sansomrb/rack-param"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_dependency "rack", "~> 1.0"
end
