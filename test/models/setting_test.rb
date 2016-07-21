require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  describe '.instance' do
    it 'gets first entry of settings' do
      first, _ = 2.times.map { Setting.create }
      assert_equal first, Setting.instance
    end

    it 'initiates new instance if empty' do
      Setting.destroy_all
      refute_nil Setting.instance
    end
  end

  describe '#amazon_config' do
    it 'provides hash with all amazon parameters' do
      Setting.create aws_access_key_id: 'key_id', aws_secret_key: 'secret_key', mws_marketplace_id: 'marketplace', mws_merchant_id: 'merchant'

      config = described_class.instance.amazon_config
      assert_equal 'key_id', config[:aws_access_key_id]
      assert_equal 'secret_key', config[:aws_secret_access_key]
      assert_equal 'merchant', config[:merchant_id]
      assert_equal 'marketplace', config[:primary_marketplace_id]
    end
  end
end
