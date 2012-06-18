require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripePlatform < OmniAuth::Strategies::OAuth2
      args :client_id

      option :client_id, nil

      option :name, 'twitter'
      option :client_options, {
        :site => 'https://manage.stripe.com'
      }
    end
  end
end
