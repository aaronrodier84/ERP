require 'test_helper'

class Users::DestroyUserTest < ActiveSupport::TestCase

  # 'before' instead of 'let' here because 'let' is lazy
  before { @user = create :user }

  let(:subject) { Users::DestroyUser.new }

  it 'destroys user' do
    assert_difference 'User.count', -1 do
      subject.call @user
    end
  end

  it 'returns successfult result' do
    result = subject.call @user
    assert result.success?
  end

  describe 'when failed to destroy user' do
    it 'returns failure result' do
      @user.stubs(:destroy).returns(false)
      result = subject.call @user
      assert result.failure?
    end
  end

  describe 'when user is nil' do
    it 'returns failure result' do
      result = subject.call nil
      assert result.failure?
    end
  end
end
