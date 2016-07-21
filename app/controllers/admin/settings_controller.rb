class Admin::SettingsController < ApplicationController
  def edit
    @setting = Setting.first
    if params[:amazon_credentials]
      render 'edit_amazon_credentials'
    elsif params[:address]
      render 'edit_address'
    end
  end

  def update
    @setting = Setting.first
    if @setting.update(settings_params)
      redirect_to admin_dashboard_index_path, notice: 'Settings were successfully updated'
    else
      render 'edit_settings'
    end
  end

  def settings_params
    permitted_attrs = [
      :aws_access_key_id, :aws_secret_key, :mws_marketplace_id, :mws_merchant_id,
      :address_name, :address_line1, :address_line2, :address_city,
      :address_state, :address_zip_code, :address_country ]
    params.require(:setting).permit(permitted_attrs)
  end

end
