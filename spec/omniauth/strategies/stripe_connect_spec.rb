require 'spec_helper'

describe OmniAuth::Strategies::StripeConnect do
  let(:fresh_strategy){ Class.new(OmniAuth::Strategies::StripeConnect) }


  before(:each) do
    OmniAuth.config.test_mode = true
    @old_host = OmniAuth.config.full_host
  end

  after(:each) do
    OmniAuth.config.full_host = @old_host
    OmniAuth.config.test_mode = false
  end

  describe '#authorize_params' do
    subject { fresh_strategy }

    it 'should include redirect_uri if full_host is set' do
      OmniAuth.config.full_host = 'https://foo.com/'
      instance = subject.new('abc', 'def')

      instance.authorize_params[:redirect_uri].should =~ /\Ahttps:\/\/foo\.com/
    end

    it 'should include redirect_uri if callback_path is set' do
      # TODO: It would be nice to grab this from the request URL
      # instead of setting it on the config
      OmniAuth.config.full_host = 'https://foo.com/'
      instance = subject.new('abc', 'def', :callback_path => 'bar/baz')

      instance.authorize_params[:redirect_uri].should == 'https://foo.com/bar/baz'
    end

    it 'should not include redirect_uri by default' do
      instance = subject.new('abc', 'def')

      expect(instance.authorize_params[:redirect_uri]).to be_nil
    end
  end

  describe '#token_params' do
    subject { fresh_strategy }

    # NOTE: We call authorize_params first in each of these methods
    # since the OAuth2 gem uses it to setup some state for testing

    it 'should include redirect_uri if full_host is set' do
      OmniAuth.config.full_host = 'https://foo.com/'
      instance = subject.new('abc', 'def')

      instance.authorize_params
      instance.token_params[:redirect_uri].should =~ /\Ahttps:\/\/foo\.com/
    end

    it 'should include redirect_uri if callback_path is set' do
      # TODO: It would be nice to grab this from the request URL
      # instead of setting it on the config
      OmniAuth.config.full_host = 'https://foo.com/'
      instance = subject.new('abc', 'def', :callback_path => 'bar/baz')

      instance.authorize_params
      instance.token_params[:redirect_uri].should == 'https://foo.com/bar/baz'
    end

    it 'should not include redirect_uri by default' do
      instance = subject.new('abc', 'def')

      instance.authorize_params
      expect(instance.token_params[:redirect_uri]).to be_nil
    end
  end
end
