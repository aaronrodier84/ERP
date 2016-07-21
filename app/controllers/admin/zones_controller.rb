class Admin::ZonesController < ApplicationController

  def index
    @zones = Zone.ordered
  end

  def edit
    @zone = Zone.find params[:id]
  end

  def update
    @zone = Zone.find params[:id]
    if @zone.update zone_params
      redirect_to admin_zones_path, notice: 'Zone successfully updated'
    else
      render 'edit'
    end
  end

  def zone_params
    params.require(:zone).permit(:production_order, :name)
  end
end
