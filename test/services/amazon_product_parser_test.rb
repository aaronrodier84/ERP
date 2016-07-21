require 'test_helper'

class AmazonProductParserTest < ActiveSupport::TestCase
  
  before do
    @source_url = 'http://ecx.images-amazon.com/images/I/41JHR6POluL._SL75_.jpg'  
    @expected_url = 'http://ecx.images-amazon.com/images/I/41JHR6POluL._SL125_.jpg'  
  end

  def price_entry(amount)
    { 'BuyingPrice' => { 'LandedPrice' => { 'Amount' => amount, 'CurrencyCode' => 'USD'}}}
  end

  let(:single_price_entry) { price_entry(100)}
  let(:multiple_prices_entry) { 3.times.map { |i| price_entry(50 + 50*i)}}

  def sample_product_info(sales_rankings, price)
    attributes = { 'Title' => 'product_title', 
                   'Size' => 10,
                   'ListPrice' => { 'Amount' => 100,
                                    'CurrencyCode' => 'USD'},
                   'SmallImage' => { 'URL' => @source_url}}

    { 'Product' => { 'AttributeSets' => {'ItemAttributes' => attributes},
                     'SalesRankings' => sales_rankings,
                     'Offers' => { 'Offer' => price}
    }}
  end

  def sample_inventory_info
    { 'SellerSKU' => 'product_sku',
      'ASIN' => 'product_asin',
      'TotalSupplyQuantity' => 100,
      'InStockSupplyQuantity' => 50,
      'FNSKU' => 'product_fnsku'
    }
  end


  let(:single_sales_rank) { { 'SalesRank' => {'Rank' => 'product_rank'}}}
  let(:multiple_sales_ranks) { { 'SalesRank' => [ {'Rank' => 'product_rank'}, { 'Rank' => 'another_product_rank'}]}}

  def expected_result
    { title: 'product_title', size: 10, list_price_amount: 100, 
      list_price_currency: 'USD', small_image_url: @expected_url,
      seller_sku: 'product_sku', asin: 'product_asin',
      total_supply_quantity: 100, in_stock_supply_quantity: 50,
      sales_rank: 'product_rank',
      selling_price_amount: 100,
      selling_price_currency: 'USD' 
    }
  end


  describe '#parse' do
    it 'correctly parses product info' do
      parser = described_class.new
      product_info = sample_product_info(multiple_sales_ranks, single_price_entry)
      result = parser.parse(sample_inventory_info, product_info)
      assert_equal expected_result, result
    end

    it 'handles single sales rank as well' do 
      parser = described_class.new
      product_info = sample_product_info(single_sales_rank, single_price_entry)
      result = parser.parse(sample_inventory_info, product_info)
      assert_equal expected_result, result
    end

    it 'takes first price when there are many' do
      parser = described_class.new
      product_info = sample_product_info(single_sales_rank, multiple_prices_entry)
      result = parser.parse(sample_inventory_info, product_info)
      assert_equal 50, result[:selling_price_amount]
      assert_equal 'USD', result[:selling_price_currency]
    end
  end

  describe '#fnsku' do
    it 'extracts fnsku from product info' do
      parser = described_class.new
      fnsku = parser.fnsku sample_inventory_info
      assert_equal 'product_fnsku', fnsku
    end
  end
end
