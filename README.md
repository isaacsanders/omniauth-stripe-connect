# Omniauth::StripePlatform

Stripe Platform OAuth2 Strategy for OmniAuth 1.0.

Supports the OAuth 2.0 server-side and client-side flows.
Read the Stripe Platform docs for more details: https://stripe.com/platform

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-stripe-platform'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-stripe-platform

## Usage

OmniAuth::Strategies::StripePlatform is simply a Rack middleware. Read the OmniAuth
1.0 docs for detailed instructions: https://github.com/intridea/omniauth.

Here's a quick example, adding the middleware to a Rails app in
`config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stripe_platform, ENV['STRIPE_PLATFORM_KEY'], ENV['STRIPE_PLATFORM_SECRET']
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
