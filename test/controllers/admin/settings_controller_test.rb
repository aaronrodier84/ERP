require 'test_helper'

class Admin::SettingsControllerTest < ActionController::TestCase

  before { quick_login_admin }
  before { Setting.create! }
  let(:setting) { Setting.first }

  describe 'GET #edit_settings for address' do
    it 'is successful' do
      get :edit, address: true
      assert_response 200
    end
  end

  describe 'GET #edit_settings for amazon credentials' do
    it 'is successful' do
      get :edit, amazon_credentials: true
      assert_response 200
    end
  end

  describe 'PATCH #edit_settings' do
    describe 'when params are ok' do
      let(:params) { {setting: { address_zip_code: "123456", mws_merchant_id: "MERCH1" }}}

      it 'redirects to dashboard' do
        patch :update, params
        assert_redirected_to admin_dashboard_index_path
      end

      it 'updates settings' do
        patch :update, params
        assert_equal "123456", setting.reload.address_zip_code
        assert_equal "MERCH1", setting.reload.mws_merchant_id
      end
    end
  end
end
