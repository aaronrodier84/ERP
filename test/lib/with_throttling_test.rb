require 'test_helper'

class WithThrottlingTest < ActiveSupport::TestCase

  def subject
    @object ||= begin
                  object = Object.new
                  object.extend(WithThrottling)
                end
  end

  describe '#throttle' do
    it 'sleeps necessary time to limit calls according to params' do
      subject.expects(:sleep).with(1)
      subject.throttle 60, per: :minute do end;
    end

    it 'returns result of passed block' do
      result = subject.throttle 100, per: :minute do
        1 + 2 
      end
      assert_equal 3, result
    end

    describe 'when interval is not supported' do
      it 'does not sleep' do
        subject.expects(:sleep).with(0)
        subject.throttle 60, per: :epoch do end;
      end
    end
  end
end
