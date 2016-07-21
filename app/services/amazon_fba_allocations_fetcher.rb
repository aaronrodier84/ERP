class AmazonFbaAllocationsFetcher
  include Logging
  include MwsStructs

  def self.build(ship_from_address)
    inbound_shipment_processor = AmazonInboundShipmentProcessor.build(ship_from_address)
    update_fba_allocation = Fba::UpdateFbaAllocation.new
    new(inbound_shipment_processor, update_fba_allocation)
  end

  def initialize(inbound_shipment_processor, update_fba_allocation)
    @inbound_shipment_processor = inbound_shipment_processor
    @update_fba_allocation_action = update_fba_allocation
  end

  def run()

    products = Product.all

    products.each do |product|

      begin

        products_to_ship = [{"product_id" => product.id, "quantity" => 100000}]

        shipment_plans_result = inbound_shipment_processor.create_shipment_plan(products_to_ship)

        if shipment_plans_result.success?
          save_warehouse_and_allocation(shipment_plans_result.entities, product)
        else
          log(shipment_plans_result.errors.join(', '))
        end

      rescue => e
        log(e.message, :error)
      end

    end
  end

  private

  # saving the warehouses and fba allocations
  def save_warehouse_and_allocation(inbound_shipment_plans, product)
    inbound_shipment_plans.each do |inbound_shipment_plan|
      warehouse = FbaWarehouse.find_or_create_by name: inbound_shipment_plan.destination_fulfillment_center_id

      inbound_shipment_plan.items.each do |item|
        fba_allocation = FbaAllocation.find_or_initialize_by fba_warehouse_id: warehouse.id, product_id: product.id
        update_fba_allocation_action.call(fba_allocation, {quantity: item.quantity})
      end
    end
  end

  attr_reader :inbound_shipment_processor, :update_fba_allocation_action
end
