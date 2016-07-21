require 'test_helper'

class InboundShipmentApiTest < ActiveSupport::TestCase

  def described_class
    Amazon::InboundShipmentApi
  end
 
  describe '.build' do
    it 'builds products api instance' do
      api = described_class.build
      assert_kind_of described_class, api
    end
  end

  describe '#create_shipment_plan' do
    let(:result) { [{ shipment_id: 123, size: 10 }] }
    let(:response) { stub(parse: result )}
    let(:items) { [{sku: 12345, quantity: 5}] }
    let(:inbound_shipment_client) { stub(create_inbound_shipment_plan: response) }
    let(:peddler_client) { stub }

    it 'requests external API for create shipment plan' do
      inbound_shipment_client.expects(:create_inbound_shipment_plan).with(anything, items).returns(response)
      api = described_class.new(inbound_shipment_client, peddler_client)
      api.create_shipment_plan items
    end

    it 'parses received response and returns result' do
      api = described_class.new(inbound_shipment_client, peddler_client)
      info = api.create_shipment_plan items
      assert_equal result, info
    end
  end

  describe '#create_shipment' do
    let(:result) { {shipment_id: 123, size: 10} }
    let(:response) { stub(parse: result )}
    let(:items) { [{sku: 12345, quantity: 5}] }
    let(:shipment_id) { 12345 }
    let(:inbound_shipment_header) { {} }
    let(:inbound_shipment_client) { stub(create_inbound_shipment: response) }
    let(:peddler_client) { stub }

    it 'requests external API for create shipment' do
      inbound_shipment_client.expects(:create_inbound_shipment).with(shipment_id, inbound_shipment_header, {inbound_shipment_items: items}).returns(response)
      api = described_class.new(inbound_shipment_client, peddler_client)
      api.create_shipment shipment_id, inbound_shipment_header, items
    end

    it 'parses received response and returns result' do
      api = described_class.new(inbound_shipment_client, peddler_client)
      info = api.create_shipment shipment_id, inbound_shipment_header, items
      assert_equal result, info
    end
  end

end
