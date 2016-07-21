require 'test_helper'

class AmazonFbaAllocationsFetcherTest < ActiveSupport::TestCase
  let(:inbound_shipment_processor) { stub }
  let(:sku) { 123 }
  let(:item) { OpenStruct.new(seller_sku: '123', quantity: 50) }
  let(:inbound_shipment_plans) { [OpenStruct.new(destination_fulfillment_center_id: 'test', items: [item])] }
  let(:shipment_plans_result) { ShipmentPlansResult.new(inbound_shipment_plans, true, []) }
  let(:update_fba_allocation) { stub(call: true)}

  before do
    product = create :product, seller_sku: sku
    inbound_shipment_processor.stubs(:create_shipment_plan).with(anything).returns(shipment_plans_result)
  end

  describe '.build' do
    it 'builds an instance of fetcher using default dependencies' do
      fetcher = AmazonFbaAllocationsFetcher.build(anything)
      assert_kind_of AmazonFbaAllocationsFetcher, fetcher
    end
  end

  describe '#run' do

    it 'creates shipment plans' do
      inbound_shipment_processor.expects(:create_shipment_plan).with(anything).returns(shipment_plans_result)
      fetcher = described_class.new inbound_shipment_processor, update_fba_allocation
      fetcher.run()
    end

    it 'saves fba warehouses and allocations' do
      update_fba_allocation.expects(:call)
      fetcher = described_class.new inbound_shipment_processor, update_fba_allocation
      fetcher.run()
    end

  end
end
