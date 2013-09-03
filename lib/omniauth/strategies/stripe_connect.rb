require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripeConnect < OmniAuth::Strategies::OAuth2
      option :name, 'stripe_connect'

      option :client_options, {
        :site => 'https://connect.stripe.com'
      }

      option :authorize_options, [:scope, :stripe_landing]
      option :provider_ignores_state, true

      uid { raw_info[:stripe_user_id] }

      info do
        {
          :scope => raw_info[:scope],
          :livemode => raw_info[:livemode],
          :stripe_publishable_key => raw_info[:stripe_publishable_key]
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.params)
      end

      def request_phase
        redirect client.auth_code.authorize_url(authorize_params.merge(request.params))
      end

      def build_access_token
        headers = {
          :headers => {
            'Authorization' => "Bearer #{client.secret}"
          }
        }
        verifier = request.params['code']
        client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)).merge(headers))
      end
    end
  end
end
