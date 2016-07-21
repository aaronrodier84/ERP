class AmazonInboundShipmentParser
  include MwsStructs

  def get_prep_details_list_to_ship(parsed_prep_instructions_response)
    prep_instructions = parse_prep_instructions(parsed_prep_instructions_response)
    result = {}
    prep_instructions.each_with_index do |instruction, index|
      result.update({"PrepDetails.#{index + 1}.PrepInstruction" => instruction, "PrepDetails.#{index + 1}.PrepOwner" => "SELLER"})
    end
    result
  end

  def parse_shipment_plans(parsed_shipment_plans_response)
    result = []

    return ShipmentPlansResult.new(result, false, ['Invalid response in creating shipment plan']) unless parsed_shipment_plans_response

    plans = parsed_shipment_plans_response['InboundShipmentPlans']['member']
    plans = [plans] if not plans.kind_of?(Array)

    result = plans.map do |plan|
      shipment_plan = OpenStruct.new
      shipment_plan.destination_fulfillment_center_id = plan['DestinationFulfillmentCenterId']
      shipment_plan.label_prep_type = plan['LabelPrepType']

      shipment_plan.ship_to_address = Address.new(
          plan['ShipToAddress']['Name'],
          plan['ShipToAddress']['AddressLine1'],
          plan['ShipToAddress']['City'],
          plan['ShipToAddress']['StateOrProvinceCode'],
          plan['ShipToAddress']['PostalCode'],
          plan['ShipToAddress']['CountryCode'],
      )

      shipment_plan.items = parse_items_on_shipment_plan(plan['Items']['member'])
      shipment_plan.shipment_id = plan['ShipmentId']

      shipment_plan

    end

    return ShipmentPlansResult.new(result, true, [])

  rescue => e
    return ShipmentPlansResult.new(result, false, [e.message])
  end

  private
  def parse_prep_instructions(parsed_prep_instructions_response)
    result = []
    return result unless parsed_prep_instructions_response

    prep_instruction_list = parsed_prep_instructions_response['SKUPrepInstructionsList']['SKUPrepInstructions']['PrepInstructionList']
    return result if prep_instruction_list.nil?

    result =  prep_instruction_list['PrepInstruction']
    if !result.kind_of?(Array)
      result = [result]
    end

    result
  end

  def parse_items_on_shipment_plan(items)
    result = []
    return result unless items

    items = [items] if not items.kind_of?(Array)

    result = items.map do |item|
      OpenStruct.new(
                      :fulfillment_network_sku => item['FulfillmentNetworkSKU'],
                      :quantity => item['Quantity'],
                      :seller_sku => item['SellerSKU'],
                      :prep_details_list => parse_prep_details_list(item['PrepDetailsList']['PrepDetails'])
      )
    end

    result
  end

  def parse_prep_details_list(prep_details)
    result = []
    return result unless prep_details

    prep_details = [prep_details] if !prep_details.kind_of?(Array)
    result = prep_details.map do |prep_detail|
      OpenStruct.new(:prep_owner => prep_detail['PrepOwner'], :prep_instruction => prep_detail['PrepInstruction'])
    end

    result
  end

end
