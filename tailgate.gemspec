# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tailgate/version'

Gem::Specification.new do |spec|
  spec.name          = "tailgate"
  spec.version       = Tailgate::VERSION
  spec.authors       = ["nathan"]
  spec.email         = ["nathan@vertile.com"]
  spec.description   = %q{the easy way to append data to a google drive spreadsheet}
  spec.summary       = %q{the easy way to append data to a google drive spreadsheet}
  spec.homepage      = ""
  spec.license       = "GPL v3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "google-api-client"
  spec.add_dependency "google_drive"
end
