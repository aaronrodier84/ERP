require 'test_helper'

class TransactionResultTest < ActiveSupport::TestCase

  test '#success? reflects result success' do
    result = described_class.new(success: true)
    assert result.success?

    result = described_class.new(success: false)
    refute result.success?
  end

  test '#failure? is opposite to success?' do
    result = described_class.new(success: true)
    refute result.failure?

    result = described_class.new(success: false)
    assert result.failure?
  end

  test 'result errors are accessible outside' do
    result = described_class.new(success: true, errors: ['just a problem'])
    assert ['just a problem'], result.errors
  end
  
  test 'result failed entities are accessible outside' do
    result = described_class.new(success: true, failed: ['just a problem'])
    assert ['just a problem'], result.failed
  end
end
