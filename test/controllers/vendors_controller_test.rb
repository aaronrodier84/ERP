require 'test_helper'

class VendorsControllerTest < ActionController::TestCase

  before { quick_login_user }

  describe 'GET #index' do
    it 'renders index' do
      get :index
      assert_template :index
    end

    it 'is successful' do
      get :index
      assert_response 200 
    end
  end

  describe 'GET #new'  do
    it 'is successful' do
      get :new
      assert_response 200
    end

    it 'renders "new"' do
      get :new
      assert_template :new
    end
  end

  describe 'GET #edit' do
    let(:vendor) { create :vendor }

    it 'renders "new" with proper vendor' do
      get :edit, id: vendor.id
      assert_template :new
    end

    it 'is successful' do
      get :edit, id: vendor.id
      assert_response 200
    end
  end

  describe 'POST #create' do
    let(:params) {{ vendor: { name: 'John Mack', website: 'http://example.com'}}}
    let(:invalid_params) {{ vendor: { name: '', website: 'http://example.com'}}}

    describe 'when creation is successful' do
      it 'redirects to all vendors page' do
        post :create, params
        assert_redirected_to vendors_path
      end
    end

    describe 'when creation failed' do
      it 'renders "new" page again' do
        post :create, invalid_params
        assert_template :new
      end
    end
  end

  describe 'PUT #update' do
    let(:vendor) { create :vendor }
    let(:params) { {id: vendor.id, vendor: { name: 'John Mack', website: 'http://example.com'}}}
    let(:invalid_params) {{ id: vendor.id, vendor: { name: '', website: 'http://example.com'}}}

    describe 'when updating is successful' do
      it 'redirects to all vendors page' do
        put :update, params
        assert_redirected_to vendors_path
      end
    end

    describe 'when updating failed' do
      it 'renders "new" page again' do
        put :update, invalid_params
        assert_template :new
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:vendor) { create :vendor }

    it 'redirects to all vendors if successful' do
      delete :destroy, id: vendor.id
      assert_redirected_to vendors_path
    end
  end
end
