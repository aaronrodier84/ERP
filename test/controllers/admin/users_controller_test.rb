require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  before { quick_login_admin }

  describe 'GET #index' do
    it 'is successful' do
      get :index
      assert_response 200
    end
  end

  describe 'GET #new' do
    it 'is successful' do
      get :new
      assert_response 200
    end

    it 'renders "new" template' do
      get :new
      assert_template :new
    end
  end

  describe 'GET #edit' do
    let(:user) { create :user }

    it 'is successful' do
      get :edit, id: user.id
      assert_response 200
    end

    it 'renders "edit" template' do
      get :edit, id: user.id
      assert_template :edit
    end
  end

  describe 'PATCH #update' do
    let(:user) { create :user, email: 'old_email@test.com'}
    let(:params) { { user: { email: 'new_email@test.com'}} }

    it 'redirects to users index on success' do
      patch :update, params.merge(id: user.id)
      assert_redirected_to admin_users_path
    end

    it 'calls an update action to update user' do
      result = stub(success?: true)
      action = mock
      action.expects(:call).with(user, {'email' => 'new_email@test.com'}).returns(result)
      @controller.stubs(:actions).returns(update_user: action)
      patch :update, params.merge(id: user.id)
    end

    describe 'when update changes password' do
      # we change password of logged in user to ensure it won't logout
      it 'signs in user again' do
        patch :update, id: @user.id, user: { password: 'new-password'}
        assert_equal @user, @controller.current_user
      end
    end

    describe 'when update failed' do
      before do
        failure_result = stub(success?: false, entity: user)
        action = mock(call: failure_result)
        @controller.stubs(:actions).returns(update_user: action)
      end

      it 'renders "edit" template' do
        patch :update, params.merge(id: user.id)
        assert_template :edit
      end
    end
  end

  describe 'POST #create' do
    let(:params) { { user: { email: 'some_email@test.com'}}}
    let(:new_user) { User.new }

    it 'redirects to users index on success' do
      post :create, params
      assert_redirected_to admin_users_path
    end

    it 'calls a create action to create user' do
      result = stub(success?: true, entity: new_user)
      action = mock
      action.expects(:call).with('email' => 'some_email@test.com').returns(result)
      @controller.stubs(:actions).returns( create_user: action)

      post :create, params
    end

    describe 'when failed to create user' do
      it 'renders "new" template' do
        result = stub(success?: false, entity: new_user )
        action = stub(call: result)
        @controller.stubs(:actions).returns(create_user: action)
        
        post :create, params
        assert_template :new
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create :user }
    it 'redirects to users index' do
      delete :destroy, id: user.id
      assert_redirected_to admin_users_path
    end

    it 'calls a destroy action to destroy user' do
      action = mock
      action.expects(:call).with(user)
      @controller.stubs(:actions).returns(destroy_user: action)

      delete :destroy, id: user.id
    end
  end
end
