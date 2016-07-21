require 'test_helper'

class Admin::ZonesControllerTest < ActionController::TestCase

  before { quick_login_admin }

  describe 'GET #index' do
    it 'is successful' do
      get :index
      assert_response 200
    end
  end

  describe 'GET #edit' do
    let(:zone) { create :zone }
    it 'is successful' do
      get :edit, id: zone.id 
      assert_response 200
    end
  end

  describe 'PATCH #update' do
    let(:zone) { create :zone, production_order: 100 }

    describe 'when params are ok' do
      let(:params) { {id: zone.id, zone: { production_order: 200 }}}

      it 'updates zone' do
        patch :update, params
        assert_equal 200, zone.reload.production_order
      end

      it 'redirects to zones index' do
        patch :update, params
        assert_redirected_to admin_zones_path
      end
    end
  end
end
