require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripePlatform < OmniAuth::Strategies::OAuth2
      option :name, 'twitter'
      option :client_options, {
        :authorize_path => '/oauth/authorize',
        :site => 'https://manage.stripe.com'
      }
    end
  end
end
