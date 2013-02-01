# OmniAuth::StripeConnect

Stripe Connect OAuth2 Strategy for OmniAuth 1.0.

Supports the OAuth 2.0 server-side and client-side flows.
Read the Stripe Connect docs for more details: https://stripe.com/connect

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-stripe-connect'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-stripe-connect

## Usage

OmniAuth::Strategies::StripeConnect is simply a Rack middleware. Read the OmniAuth
1.0 docs for detailed instructions: https://github.com/intridea/omniauth.

Here's a quick example, adding the middleware to a Rails app in
`config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stripe_connect, ENV['STRIPE_CONNECT_CLIENT_ID'], ENV['STRIPE_SECRET']
end
```

Your `STRIPE_CONNECT_CLIENT_ID` is application-specific and your `STRIPE_SECRET` is account-specific and may also be known as your Stripe API key or Stripe Private key.

Edit your routes.rb file to have:
`devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }`

And create a file called `omniauth_callbacks_controller.rb` which should have this inside:
```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def stripe_connect
    raise request.env["omniauth.auth"].to_yaml
  end
end
```

Make sure to go to Stripe's Account Settings > Applications and set your Redirect URL to:
`http://localhost:3003/users/auth/stripe_connect/callback`

The Webhook URL will be something similar:
`http://www.yourdomain.com/users/auth/stripe_connect/callback`

Then you can hit `/auth/stripe_connect`

If you hit `/auth/stripe_connect` with any query params, they will be passed along to Stripe. Read [Stripe's OAuth Reference](https://stripe.com/docs/connect/reference) for more information.

### Ruby on Rails apps with Devise

After setting up Devise to use OmniAuth, you only need to add the following line of code to handle the OAuth2 part of Stripe Connect.

```ruby
# Put this in config/initializers/devise.rb with the rest of your Devise configuration
config.omniauth :stripe_connect,
  ENV['STRIPE_CONNECT_CLIENT_ID'],
  ENV['STRIPE_SECRET_KEY'],
  :scope => 'read_write', # or :scope => 'read_only'
  :stripe_landing => 'login' # or :stripe_landing => 'register'
```

Now your done!

## Auth Hash

Here is an example of the Auth Hash you get back from calling `request.env['omniauth.auth']`:

```ruby
{
  "provider"=>"stripe_connect",
  "uid"=>"<STRIPE_USER_ID>",
  "info"=> {
    "scope"=>"read_write", # or "read_only"
    "livemode"=>false,
    "stripe_publishable_key"=>"<STRIPE_PUBLISHABLE_KEY>",
  },
  "credentials"=> {
    "token"=>"<STRIPE_ACCESS_TOKEN>",
    "expires"=>false
  },
  "extra"=> {
    "raw_info"=> {
      "token_type"=>"bearer",
      "stripe_user_id"=>"<STRIPE_USER_ID>",
      "scope"=>"read_only",
      "stripe_publishable_key"=>"<STRIPE_PUBLISHABLE_KEY>",
      "livemode"=>false
    }
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
