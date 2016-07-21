class VendorsController < ApplicationController

  before_filter :find_vendor, :except => [:index, :new, :create]

  def index
    @vendors = Vendor.all
  end

  def new
    @vendor = Vendor.new
  end

  def edit
    render 'new'
  end

  def show
  end

  def create
    @vendor = Vendor.new request_params
    if @vendor.save
      redirect_to vendors_path, notice: "Vendor successfully created"
    else
      render 'new'
    end
  end

  def update
    if @vendor.update_attributes request_params
      redirect_to vendors_path, notice: "Vendor successfully updated"
    else
      render 'new'
    end
  end

  def destroy
    @vendor.destroy
    redirect_to vendors_path, notice: "Vendor successfully deleted."
  end

  private

    def find_vendor
      @vendor = Vendor.find(params[:id])
    end

    def request_params
      params.require(
        :vendor).permit(
        :name,
        :contact_name,
        :phone,
        :contact_email,
        :order_email,
        :website,
        :tags,
        :address,
				:notes
      )
    end

end
