# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/mit_oauth2/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-mit-oauth2"
  spec.version       = OmniAuth::MITOAuth2::VERSION
  spec.authors       = ["Mike Graves"]
  spec.email         = ["mgraves@mit.edu"]

  spec.summary       = %q{OmniAuth strategy for MIT OIDC}
  spec.description   = %q{OmniAuth strategy for MIT OIDC}
  spec.homepage      = "https://github.com/MITLibraries/omniauth-mit-oauth2"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'omniauth-oauth2', '~> 1.1'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
