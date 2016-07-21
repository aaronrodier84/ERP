require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  before { quick_login_admin }
  before { Setting.create! }

  describe 'GET #index' do
    it 'is successful' do
      get :index
      assert_response 200
    end
  end

  describe 'GET #fetch_products' do
    it 'redirects to admin dashboard' do
      get :fetch_products
      assert_redirected_to admin_dashboard_index_path
    end

    it 'fetches products asynchronously' do
      assert_enqueued_with(job: FetchProductsJob) do
        get :fetch_products
      end
    end

    it 'updates inventories asynchronously' do
      assert_enqueued_with(job: UpdateAmazonInventoryJob) do
        get :fetch_products
      end
    end
  end

  describe 'GET #refresh_fba_allocations' do
    it 'redirects to admin dashboard' do
      get :refresh_fba_allocations
      assert_redirected_to admin_dashboard_index_path
    end

    it 'fetch fba allocations asynchronously' do
      assert_enqueued_with(job: FetchFbaAllocationsJob) do
        get :refresh_fba_allocations
      end
    end
  end

end
