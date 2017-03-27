module OmniAuth
  module Strategies
    class StripeConnectProduction < OmniAuth::StripeConnect::SharedStrategy
      option :name, :stripe_connect_production
    end
  end
end
