module OmniAuth
  module Strategies
    class StripeConnectDevelopment < OmniAuth::StripeConnect::SharedStrategy
      option :name, :stripe_connect_development
    end
  end
end
