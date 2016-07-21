require 'test_helper'

class PasswordGeneratorTest < ActiveSupport::TestCase

  let(:subject) { described_class.new }

  describe '#generate' do
    it 'generates 8 symbols password by default' do
      password = subject.generate
      refute_nil password
      assert_equal 8, password.length
    end

    it 'generates password of specified length' do
      password = subject.generate 16
      refute_nil password
      assert_equal 16, password.length
    end
  end
end
