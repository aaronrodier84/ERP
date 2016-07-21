require 'test_helper'

class AmazonInboundShipmentProcessorTest < ActiveSupport::TestCase
  let(:inbound_shipment_api) { stub(get_prep_instructions_for_sku: {}) }
  let(:inbound_shipment_parser) { stub(get_prep_details_list_to_ship: {}) }
  let(:sku) { 123 }
  let(:item) { OpenStruct.new(seller_sku: '123', quantity: 50) }
  let(:inbound_shipment_plans) { [OpenStruct.new(destination_fulfillment_center_id: 'test', items: [item])] }
  let(:shipment_plans_result) { ShipmentPlansResult.new(inbound_shipment_plans, true, []) }
  let(:product) { create :product, seller_sku: sku }
  let(:products_to_ship) { [{"product_id" => product.id, "quantity" => 100}] }

  def described_class
    AmazonInboundShipmentProcessor
  end

  describe '.build' do
    it 'builds an instance of processor using default dependencies' do
      processor = described_class.build(anything)
      assert_kind_of described_class, processor
    end
  end

  describe '#create_shipment_plan' do

    before do
      inbound_shipment_api.stubs(:create_shipment_plan).with(anything).returns(anything)
      inbound_shipment_parser.stubs(:parse_shipment_plans).with(anything).returns(shipment_plans_result)
    end

    it 'return shipment plans result successfully' do
      inbound_shipment_api.expects(:create_shipment_plan).with(anything).returns(anything)
      inbound_shipment_parser.expects(:parse_shipment_plans).with(anything).returns(shipment_plans_result)
      processor = described_class.new inbound_shipment_api, inbound_shipment_parser
      processor.create_shipment_plan(products_to_ship)
    end

  end

  describe '#create_shipment' do

    before do
      inbound_shipment_api.stubs(:create_shipment).with(anything, anything, anything).returns(anything)
    end

    it 'return shipment response successfully' do
      inbound_shipment_api.expects(:create_shipment).with(anything, anything, anything).returns(anything)
      processor = described_class.new inbound_shipment_api, inbound_shipment_parser
      processor.create_shipment('test', inbound_shipment_plans.first)
    end

  end

end
