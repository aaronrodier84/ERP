module Amazon
  class InboundShipmentApi
    include Logging

    def self.build(config = {})
      inbound_shipment_client ||= MWS::FulfillmentInboundShipment::Client.new
      peddler_client ||= Peddler::Client.new
		  new(inbound_shipment_client, peddler_client, config)
    end

    def initialize(inbound_shipment_client, peddler_client, options = {})
      @inbound_shipment_client = inbound_shipment_client
      @peddler_client = peddler_client
      @ship_from_address = options.fetch(:ship_from_address, {})
    end

    def get_prep_instructions_for_sku(sku)
      peddler_client.version = '2010-10-01'
      peddler_client.path = "/FulfillmentInboundShipment/#{peddler_client.version}"
      peddler_client.operation('GetPrepInstructionsForSKU').add({'SellerSKUList' => [sku], 'ShipToCountryCode' => 'US'}).structure!('SellerSKUList', 'Id')
      response = peddler_client.run
      response.parse
    rescue => e
      log(e.message, :error)
      nil
    end

    def create_shipment_plan(items)
      shipment_plans = inbound_shipment_client.create_inbound_shipment_plan(ship_from_address, items)
      shipment_plans.parse
    rescue => e
      log(e.message, :error)
      nil
    end

    def create_shipment(shipment_id, inbound_shipment_header, inbound_shipment_items_shipped)
      create_inbound_shipment_response = inbound_shipment_client.create_inbound_shipment(shipment_id, inbound_shipment_header, {inbound_shipment_items: inbound_shipment_items_shipped})
      create_inbound_shipment_response.parse
    rescue => e
      log(e.message, :error)
      nil
    end

    private
    attr_reader :inbound_shipment_client, :peddler_client, :ship_from_address
  end
end

