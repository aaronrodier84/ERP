require 'test_helper'

class ProductsApiTest < ActiveSupport::TestCase

  def described_class
    Amazon::ProductsApi
  end
 
  describe '.build' do
    it 'builds products api instance' do
      api = Amazon::ProductsApi.build
      assert_kind_of Amazon::ProductsApi, api
    end
  end

  describe '#fetch_inventories' do
    let(:first_inventory) { { 'NextToken' => '123' } }
    let(:last_inventory) {{ 'NextToken' => nil}}
    let(:initial_response) { stub(parse: first_inventory)}
    let(:last_response) { stub(parse: last_inventory)}

    let(:inventory_client) { stub(list_inventory_supply: initial_response,
                                 list_inventory_supply_by_next_token: last_response) }
    let(:product_client) { Object.new }

    it 'fetches inventories' do
      api = described_class.new(inventory_client, product_client)
      inventories = api.fetch_inventories('2010-10-01')
      assert_equal [first_inventory, last_inventory], inventories
    end
  end

  describe '#fetch_product_info' do
    let(:result) { { fnsku: 123, size: 10 }}
    let(:response) { stub(parse: result )}
    let(:asin) { 12345 }
    let(:inventory_client) { stub }
    let(:product_client) { stub(get_matching_product: response) }

    it 'requests external API for product info' do
      product_client.expects(:get_matching_product).with(asin, anything).returns(response)
      api = described_class.new(inventory_client, product_client) 
      api.fetch_product_info asin
    end

    it 'parses received response and returns result' do
      api = described_class.new(inventory_client, product_client) 
      info = api.fetch_product_info asin
      assert_equal result, info
    end
  end


end
