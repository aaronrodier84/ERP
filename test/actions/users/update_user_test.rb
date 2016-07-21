require 'test_helper'

class Users::UpdateUserTest < ActiveSupport::TestCase

  let(:user) { create :user, email: 'email_before@test.com'}

  let(:subject) { Users::UpdateUser.new }
  it 'updates user' do
    subject.call user, email: 'email_after@test.com'
    assert_equal 'email_after@test.com', user.reload.email 
  end

  it 'returns successfult result' do
    result = subject.call user, email: 'new@email.com'
    assert result.success?
  end

  describe 'when user params are invalid' do
    it 'returns failure result' do
      result = subject.call user, email: nil
      assert result.failure?
    end
  end

  describe 'when use is nil' do
    it 'returns failure result' do
      result = subject.call nil, email: 'new@email.com'
      assert result.failure?
    end
  end
end
