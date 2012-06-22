require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripePlatform < OmniAuth::Strategies::OAuth2
      option :name, 'stripe-platform'

      args :client_id

      option :client_id, nil

      option :client_options, {
        :site => 'https://manage.stripe.com'
      }

      uid { raw_info[:stripe_user_id] }

      info do
        {
          :scope => raw_info[:scope],
          :livemode => raw_info[:livemode],
          :access_token => raw_info[:access_token],
          :expires_in => raw_info[:expires_in],
          :stripe_publishable_key => raw_info[:stripe_publishable_key]
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        if access_token.expires? && access_token.expired?
          @raw_info = access_token.refresh!
        else
          @raw_info ||= access_token.post(access_token.client.token_url).parsed || {}
        end
      end
    end
  end
end
