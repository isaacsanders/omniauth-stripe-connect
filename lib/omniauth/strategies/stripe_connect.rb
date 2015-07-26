require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripeConnect < OmniAuth::Strategies::OAuth2
      option :name, :stripe_connect

      option :client_options, {
        :site => 'https://connect.stripe.com'
      }

      option :authorize_options, [:scope, :stripe_landing, :always_prompt]
      option :provider_ignores_state, true

      uid { raw_info[:stripe_user_id] }

      info do
        {
          :name => extra_info[:display_name] || extra_info[:business_name] || extra_info[:email],
          :email => extra_info[:email],
          :nickname => extra_info[:display_name],
          :scope => raw_info[:scope],
          :livemode => raw_info[:livemode],
          :stripe_publishable_key => raw_info[:stripe_publishable_key]
        }
      end

      extra do
        e = {
          :raw_info => raw_info
        }
        e[:extra_info] = extra_info unless skip_info?

        e
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.refresh_token
        hash.merge!('expires_at' => access_token.expires_at) if access_token.expires?
        hash.merge!('expires' => access_token.expires?)
        hash
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.params)
      end

      def extra_info
        @extra_info ||= deep_symbolize(access_token.get("https://api.stripe.com/v1/account").parsed)
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
