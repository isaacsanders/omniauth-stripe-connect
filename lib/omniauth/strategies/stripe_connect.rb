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

      def redirect_params
        if options.key?(:callback_path) || OmniAuth.config.full_host
          {:redirect_uri => callback_url}
        else
          {}
        end
      end

      # NOTE: We call redirect_params AFTER super in these methods intentionally
      # the OAuth2 strategy uses the authorize_params and token_params methods
      # to set up some state for testing that we need in redirect_params

      def authorize_params
        params = super
        params = params.merge(request.params) unless OmniAuth.config.test_mode
        redirect_params.merge(params)
      end

      def token_params
       params = super.to_hash(:symbolize_keys => true) \
          .merge(:headers => { 'Authorization' => "Bearer #{client.secret}" })

        redirect_params.merge(params)
      end

      def request_phase
        redirect client.auth_code.authorize_url(authorize_params)
      end

      def build_access_token
        verifier = request.params['code']
        client.auth_code.get_token(verifier, token_params)
      end
    end
  end
end
