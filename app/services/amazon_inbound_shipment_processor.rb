class AmazonInboundShipmentProcessor
  include MwsStructs

  def self.build(ship_from_address)
    inbound_shipment_api = Amazon::InboundShipmentApi.build({:ship_from_address => ship_from_address})
    inbound_shipment_parser = AmazonInboundShipmentParser.new
    new(inbound_shipment_api, inbound_shipment_parser)
  end
  def initialize(inbound_shipment_api, inbound_shipment_parser)
    @inbound_shipment_api = inbound_shipment_api
    @inbound_shipment_parser = inbound_shipment_parser
  end

  def create_shipment_plan(products_to_ship)
    inbound_shipment_items = build_inbound_shipment_items(products_to_ship)

    # create shipment plans by calling amazon api and returns the response parsed simply using xml parser
    parsed_shipment_plans_response = inbound_shipment_api.create_shipment_plan(inbound_shipment_items)

    #  parse the simply parsed response to the shipment plans result object structurized
    shipment_plans_result = inbound_shipment_parser.parse_shipment_plans(parsed_shipment_plans_response)

    shipment_plans_result
  end

  def create_shipment(shipment_name, inbound_shipment_plan)
    inbound_shipment_header = InboundShipmentHeader.new(shipment_name, ship_from_address, inbound_shipment_plan.destination_fulfillment_center_id, "WORKING", "SELLER_LABEL")

    items = inbound_shipment_plan.items

    inbound_shipment_items_shipped = items.map { |item| ItemShipped.new(item.seller_sku, item.quantity, get_prep_details_list_to_ship(item.seller_sku)) }

    # create inbound shipment
    parsed_shipment_response = inbound_shipment_api.create_shipment(inbound_shipment_plan.shipment_id, inbound_shipment_header, inbound_shipment_items_shipped)

    parsed_shipment_response
  end

  private
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

  attr_reader :inbound_shipment_api, :inbound_shipment_parser
end
