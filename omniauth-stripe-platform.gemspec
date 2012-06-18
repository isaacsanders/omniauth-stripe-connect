# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-stripe-platform/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Isaac Sanders"]
  gem.email         = ["isaac@isaacbfsanders.com"]
  gem.description   = %q{Stripe Platform OAuth2 Strategy for OmniAuth 1.0.}
  gem.summary       = %q{
Supports the OAuth 2.0 server-side and client-side flows.
Read the Stripe Platform docs for more details: https://stripe.com/platform
}
  gem.homepage      = "https://github.com/intridea/omniauth/wiki"

  gem.files         = `git ls-files | grep -v example`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "omniauth-stripe-platform"
  gem.require_paths = ["lib"]
  gem.version       = Omniauth::StripePlatform::VERSION

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-oauth2', '~> 1.0'
end
