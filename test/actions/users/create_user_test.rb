require 'test_helper'

class Users::CreateUserTest < ActiveSupport::TestCase

  it 'creates user record' do
    action = Users::CreateUser.new 
    assert_difference 'User.count', +1 do
      action.call email: 'test@email.com'
    end
  end

  it 'generates password for user' do
    password_generator = mock(generate: 'new-password')
    action = Users::CreateUser.new password_generator
    result = action.call email: 'test@email.com'
    user = result.entity
    assert 'new-password', user.password
  end

  it 'returns successful result' do
    action = Users::CreateUser.new
    result = action.call email: 'test@email.com'
    assert result.success?
  end

  describe 'when params are invalid' do
    it 'returns failure result' do
      action = Users::CreateUser.new
      result = action.call email: nil
      assert result.failure?
    end
  end

end
