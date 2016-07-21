require 'test_helper'

class AmazonProductsFetcherTest < ActiveSupport::TestCase
  let(:parser) { stub(parse: true, fnsku: '12345' )}
  let(:products_api) { stub(fetch_product_price: {}) }
  let(:inventory_item) { { 'ASIN' => 123 }}
  let(:date) { Date.today.to_s(:is8601) }

  let(:create_action) { stub(call: true)}
  let(:update_action) { stub(call: true)}
  let(:product_actions) { { create: create_action, update: update_action} }


  before do
    @inventories = 3.times.map do |index|
      member = { 'member' => { 'ASIN' => index }}
      { 'InventorySupplyList' => member }
    end
    products_api.stubs(:fetch_inventories).returns(@inventories)
    parser.stubs(:parse).returns({})

    # stub sleep to remove embedded throttling
    described_class.any_instance.stubs(:sleep)
  end

  describe '.build' do
    it 'builds an instance of fetcher using default dependencies' do
      fetcher = AmazonProductsFetcher.build
      assert_kind_of AmazonProductsFetcher, fetcher
    end
  end

  describe '#run' do

    it 'fetches inventories from amazon from specified date' do
      products_api.expects(:fetch_inventories).with(date).returns([])
      fetcher = described_class.new(products_api, parser, product_actions)
      fetcher.run(date)
    end

    describe 'for each received inventory item' do
      
      it 'fetchs product info' do
        products_api.expects(:fetch_product_info).times(3)

        fetcher = described_class.new(products_api, parser, product_actions)
        fetcher.run(date)
      end
    end

    it 'parses received data with specified parser' do
      product_info = OpenStruct.new
      products_api.stubs(:fetch_product_info).returns(product_info)
      parser.expects(:parse).with(anything,{}).once
      fetcher = described_class.new(products_api, parser, product_actions)
      fetcher.run date
    end

    describe 'when product with fnsku already exists' do
      let(:parser) { stub(parse: true, fnsku: 'valid_fnsku' )}

      before do
        create :product, fnsku: 'valid_fnsku'
      end

      it 'updates that product' do
        update_action.expects(:call).once
        actions = { update: update_action }
        product_info = OpenStruct.new fnsku: 100, data: { size: 100}
        products_api.stubs(:fetch_product_info).returns(product_info)

        fetcher = described_class.new(products_api, parser, actions)
        fetcher.run date
      end
    end
  end
end
