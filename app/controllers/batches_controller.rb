class BatchesController < ApplicationController
  include FormattedDate
  include MwsStructs
  include Logging

  def index
    batches = Batch.fresh_first.includes(:zone, :product, :users)
    render locals: { batches: batches }
  end

  def get_chart_data
    batches = Batch.where(completed_on: params[:date_range].to_i.days.ago..Date.today).order(completed_on: :desc).group_by { |record| [record.completed_on] }

    days = batches.keys.map { |day| day.to_s }
    chart_data = Zone.all.map do |zone|

      data = batches.map {|one_day, records| records.select { |record| record.zone_id == zone.id }.sum(&:quantity) }
      {name: zone.name, data: data}

    end

    respond_to do |format|
      format.json { render json: {days: days, chart_data: chart_data}, status: :ok }
    end

  end

  def new
    product = Product.find_by id: params[:product_id]
    zone = Zone.fetch_or_default params[:zone_id]
    batch = Batch.new( completed_on: Date.today, user_ids: [current_user.id], zone: zone, product: product )

    presenter = BatchPresenter.new batch
    render locals: { presenter: presenter }
  end

  def edit
    batch = Batch.find_by id: params[:id]
    presenter = BatchPresenter.new batch
    render locals: { presenter: presenter }
  end

  def show
    batch = Batch.find_by id: params[:id]
    render locals: { batch: batch }
  end

  def create
    result = actions[:create_batch].call(batch_params)
    if result.success?
      redirect_to batches_path, notice: "Batch successfully created"
    else
      presenter = BatchPresenter.new result.entity
      flash[:error] = result.error_message
      render :new, locals: { presenter: presenter }
    end
  end

  def create_with_shipment
    products_to_ship = JSON.parse(params[:productsToShip])
    shipment_name = params[:shipmentName]
    warehouse_id = params[:warehouseId]
    warehouse = FbaWarehouse.find(warehouse_id)

    json_response_with_error({code: 'err_overflow_inventory'}) and return if !valid_quantity_to_ship(products_to_ship, warehouse)

    shipment_plans_result = inbound_shipment_processor.create_shipment_plan(products_to_ship)

    json_response_with_error({code: 'err_create_shipment_plans'}) and return if !shipment_plans_result.success?

    shipment_plans_result.entities.each do |inbound_shipment_plan|

      if inbound_shipment_plan.destination_fulfillment_center_id == warehouse.name

        # create inbound shipment
        parsed_shipment_response = inbound_shipment_processor.create_shipment(shipment_name, inbound_shipment_plan)

        json_response_with_error({code: 'err_create_shipment'}) and return unless parsed_shipment_response

        # create batches for each product of this shipment here
        create_batches_from_items(inbound_shipment_plan.items, inbound_shipment_plan)

      end

    end

    respond_to do |format|
      format.json { render json: products_to_ship, status: :ok }
    end

  rescue => e
    # unknown exception
    json_response_with_error({code: 'err_unknown'}) and return
  end

  def update
    batch = Batch.find_by id: params[:id]
    result = actions[:change_batch].call(batch, batch_params)

    if result.success?
      redirect_to batches_path, notice: "Batch successfully updated"
    else
      presenter = BatchPresenter.new result.entity
      flash[:error] = result.error_message
      render :edit, locals: { presenter: presenter }
    end
  end

  def destroy
    batch = Batch.find_by id: params[:id]
    result = actions[:destroy_batch].call batch
    if result.success?
      redirect_to batches_path, notice: "Batch successfully deleted."
    else
      flash[:error] = result.error_message
      redirect_to batches_path
    end
  end

  private

    def actions
      { create_batch: CreateBatch.new,
        change_batch: ChangeBatch.new,
        destroy_batch: DestroyBatch.new
      }
    end

    def batch_params
      params.require(
        :batch).permit(
        :product_id,
        :quantity,
        :completed_on,
        :zone_id,
				:notes,
        { :user_ids => [] }
      )
    end

    def build_batch_params(item)
      {
          product_id: Product.find_by(seller_sku: item.seller_sku).id,
          quantity: item.quantity,
          completed_on: Date.today.strftime("%m/%d/%Y"),
          zone_id: Zone.find_by(name: 'Ship').id,
          user_ids: [current_user.id]
      }
    end

    def valid_quantity_to_ship(products_to_ship, warehouse)
      products_to_ship.each do |p|
        product = Product.find(p["product_id"])
        quantity = p['quantity'].to_i
        quantity_is_valid = ProductFbaAllocationPlan.new(product, quantity).valid_against?(warehouse)
        return false unless quantity_is_valid
      end
      return true
    end

    def build_inbound_shipment_items(products_to_ship)
      inbound_shipment_items = products_to_ship.map do |p|
        product = Product.find(p["product_id"])

        prep_details_list = get_prep_details_list_to_ship(product.seller_sku)
        Item.new(product.seller_sku, p["quantity"], prep_details_list)
      end

      inbound_shipment_items
    end

    def get_prep_details_list_to_ship(sku)
      parsed_prep_instructions_response = inbound_shipment_api.get_prep_instructions_for_sku(sku)
      prep_details_list = inbound_shipment_parser.get_prep_details_list_to_ship(parsed_prep_instructions_response)
      prep_details_list
    end

    def create_batches_from_items(items, inbound_shipment_plan)
      items.each do |item|
        result = actions[:create_batch].call(build_batch_params(item))
        if !result.success?
          log "creating batch fails for the item (sku: #{item.seller_sku}) under the shipment(#{inbound_shipment_plan.shipment_id})"
        end
      end
    end

    def json_response_with_error(error)
      respond_to do |format|
        format.json { render json: {error: error}, status: :unprocessable_entity }
      end
    end

    def inbound_shipment_processor
      @inbound_shipment_processor ||= AmazonInboundShipmentProcessor.build(ship_from_address)
    end

end
