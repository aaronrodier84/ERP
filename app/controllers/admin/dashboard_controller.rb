class Admin::DashboardController < ApplicationController

  def index
    @setting = Setting.first
  end

  def fetch_products
    FetchProductsJob.perform_later
    UpdateAmazonInventoryJob.perform_later
    redirect_to admin_dashboard_index_path, notice: 'Started background products and inventory update'
  end

  def refresh_fba_allocations
    FetchFbaAllocationsJob.perform_later
    redirect_to admin_dashboard_index_path, notice: 'Started background fba allocations updated'
  end

end
