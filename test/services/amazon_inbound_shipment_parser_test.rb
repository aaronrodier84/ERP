require 'test_helper'

class AmazonInboundShipmentParserTest < ActiveSupport::TestCase

  def prep_instructions_info
    {
        "SKUPrepInstructionsList" => {
            "SKUPrepInstructions" => {
                "PrepInstructionList" => {
                    "PrepInstruction" => [
                        "Label1", "Label2"
                    ]
                }
            }
        }
    }
  end

  def expected_prep_details_list
    {
        "PrepDetails.1.PrepInstruction" => "Label1",
        "PrepDetails.1.PrepOwner" => "SELLER",
        "PrepDetails.2.PrepInstruction" => "Label2",
        "PrepDetails.2.PrepOwner" => "SELLER",
    }
  end

  def shipment_plans_info
    {
        "InboundShipmentPlans" => {
            "member" => [
                {
                    "DestinationFulfillmentCenterId" => "PHX7",
                    "LabelPrepType" => "SELLER_LABEL",
                    "ShipToAddress" => {
                        "City" => "city",
                        "CountryCode" => "US",
                        "PostalCode" => "12345",
                        "Name" => "name",
                        "AddressLine1" => "address line 1",
                        "StateOrProvinceCode" => "CA"
                    },
                    "Items" => {
                        "member" => [
                            {
                                "FulfillmentNetworkSKU" => "test",
                                "Quantity" => 50,
                                "SellerSKU" => "12345",
                                "PrepDetailsList" => {
                                    "PrepDetails" => [
                                        "PrepOwner" => "SELLER",
                                        "PrepInstruction" => "Labeling"
                                    ]
                                }
                            }
                        ]
                    },
                    "ShipmentId" => "12345"
                }
            ]
        }
    }
  end

  def expected_shipment_plans_result
    ShipmentPlansResult.new(
        [
            OpenStruct.new(
                :destination_fulfillment_center_id => "PHX7",
                :label_prep_type => "SELLER_LABEL",
                :ship_to_address => OpenStruct.new(
                    :city => "city",
                    :country_code => "US",
                    :postal_code => "12345",
                    :name => "name",
                    :address_line1 => "address line 1",
                    :state_or_province_code => "CA"
                ),
                :items => [
                    OpenStruct.new(
                        :fulfillment_network_sku => "test",
                        :quantity => 50,
                        :seller_sku => "12345",
                        :prep_details_list => [
                            OpenStruct.new(:prep_owner => "SELLER", :prep_instruction => "Labeling")
                        ]
                    )
                ],
                :shipment_id => "12345"
            )
        ],
        true,
        []
    )

  end

  describe '#get_prep_details_list_to_ship' do
    it 'correctly parses prep details list' do
      parser = described_class.new
      result = parser.get_prep_details_list_to_ship(prep_instructions_info)
      assert_equal expected_prep_details_list, result
    end

    it 'parses prep details list with wrong response' do
      parser = described_class.new
      result = parser.get_prep_details_list_to_ship(nil)
      blank_result = {}
      assert_equal blank_result, result
    end
  end

  describe '#parse_shipment_plans' do
    it 'correctly parses inbound shipment plans' do
      parser = described_class.new
      result = parser.parse_shipment_plans(shipment_plans_info)
      assert_equal expected_shipment_plans_result.success?, result.success?
    end

    it 'parses inbound shipment plans with wrong response' do
      parser = described_class.new
      result = parser.get_prep_details_list_to_ship(nil)
      blank_result = {}
      assert_equal blank_result, result
    end
  end

end
