# frozen_string_literal: true
class ProductsController < ApplicationController
  before_filter :find_product, :only => [:update, :barcode, :save_internal_title]

  def index
    if params[:archived]
      products = Product.inactive
      @products_presenter = ProductsPresenter.new products
      render 'index_archived'
    else
      zones = current_user.zones.ordered
      current_zone = Zone.default_zone
      render 'index', locals: { zones: zones, current_zone: current_zone }
    end
  end

  def products_at_zone
    zone = Zone.fetch_or_default params[:zone_id]
    products_presenter = ProductsPresenter.new zone.active_products, zone

    if zone.ship?
      render partial: 'products_as_ship_table', locals: { presenter: products_presenter }
    else
      render partial: 'products_as_tiles', locals: { presenter: products_presenter }
    end
  end

  def update
    actions[:update_product].call @product, request_params
    respond_to do |format|
      format.html { redirect_to product_path, id: @product.id }
      format.json do
        # incoming params: {"product"=>{"to_ship_case_qty_override"=>"111"}, "id"=>"153"}
        plan_json = ProductFbaAllocationPlan.new(@product, @product.to_allocate_item_quantity).generate_json
        render json: plan_json
      end
    end
  end

  def save_internal_title
    @product.internal_title = params[:internal_title]
    respond_to do |format|
      if @product.save
        format.html { redirect_to product_path(@product), notice: 'Product was successfully updated.' }
        format.json { render json: @product, status: :ok }
      else
        format.html { render product_path(@product) }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @product = Product.includes(:ingredients => :material).find(params[:id])
    @presenter = ProductPresenter.new(@product)
  end

  def barcode
    generator = BarcodeGenerator.new
    generator.create_barcode @product.title, @product.fnsku, "tmp/barcode.pdf"

    respond_to do |format|
      format.pdf do
        pdf_filename = File.join(Rails.root, "tmp/barcode.pdf")
        send_file(pdf_filename, :filename => "my.pdf", :disposition => 'inline', :type => "application/pdf")
      end
    end
  end

  def actions
    { update_product: Products::UpdateProduct.new }
  end

  private
  def request_params
    params.require(:product).permit(:to_ship_case_qty_override, :to_ship_item_qty_override,
                                    :items_per_case, :production_buffer_days,
                                    :batch_min_quantity, :batch_max_quantity,
                                    :is_active, zone_ids: [])
  end

  def find_product
    @product = Product.find(params[:id])
  end
end
