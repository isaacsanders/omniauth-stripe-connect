require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripeConnect < OmniAuth::Strategies::OAuth2
      option :name, :stripe_connect
      option :jwt_hmac_secret, nil

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

      # Manually create a state param, with JWT.
      def authorize_params
        if !OmniAuth.config.test_mode
          options.authorize_params[:state] = generate_jwt_state(request.params)
          # Remove querystring params as only `state` is allowed.
          request.params.clear
        end
        params = options.authorize_params.merge(options_for("authorize"))
        if OmniAuth.config.test_mode
          @env ||= {}
          @env["rack.session"] ||= {}
        end
        session["omniauth.state"] = params[:state]
        redirect_params.merge(params)
      end

      # Do validation callbacks, then manually set 'omniauth.params' with decoded JWT.
      def callback_phase # rubocop:disable AbcSize, CyclomaticComplexity, MethodLength, PerceivedComplexity
        super
        @env['omniauth.params'] = decode_jwt_state(session['omniauth.state'])
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

      # Stripe does not allow query string for callback_url. override base strategy.
      def callback_url
        full_host + script_name + callback_path
      end

      def generate_jwt_state(params, hmac_secret = options[:jwt_hmac_secret])
        payload = {_state: SecureRandom.hex(24)}
        payload = params.merge(payload) unless params.nil?
        # use hmac if it is set.
        if hmac_secret.nil?
          jwt = JWT.encode(payload, nil, 'none')
        else
          jwt = JWT.encode(payload, hmac_secret, 'HS256')
        end
        jwt
      end

      def decode_jwt_state(jwt, hmac_secret = options[:jwt_hmac_secret])
        if hmac_secret.nil?
          payload = JWT.decode(jwt, nil, false)
        else
          payload = JWT.decode(jwt, hmac_secret, true)
        end
        payload.first.delete("_state")
        payload.first
      end
    end
  end
end
