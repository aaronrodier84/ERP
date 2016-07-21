class AmazonProductParser
  include Logging

  def parse(inventory_info, product_info)
    product_attributes = product_info.dig('Product', 'AttributeSets', 'ItemAttributes')

    product_price = product_info.dig('Product', 'Offers', 'Offer')

    product_attributes_data = parse_product_attributes(product_attributes).to_h
    product_inventory_data = parse_inventory_data(inventory_info).to_h
    product_price_data = parse_product_price(product_price)

    combined_result = product_attributes_data.merge(product_inventory_data).merge(product_price_data)
    combined_result.merge sales_rank_info(product_info)
  end

  def fnsku(inventory_info)
    return nil unless inventory_info
    inventory_info['FNSKU']
  end

  private

  def parse_product_attributes(product_attributes)
    result = OpenStruct.new
    return result unless product_attributes

    result.title = product_attributes['Title']
    result.size = product_attributes['Size']
    result.list_price_amount = product_attributes.dig('ListPrice', 'Amount')
    result.list_price_currency = product_attributes.dig('ListPrice', 'CurrencyCode')
    result.small_image_url = small_image_url(product_attributes)
    result
  end

  def parse_inventory_data(inventory_info)
    result = OpenStruct.new
    return result unless inventory_info

    result.seller_sku = inventory_info['SellerSKU']
    result.asin = inventory_info['ASIN']
    result.total_supply_quantity = inventory_info['TotalSupplyQuantity']
    result.in_stock_supply_quantity = inventory_info['InStockSupplyQuantity']
    result
  end

  def parse_product_price(product_price)
    return {} unless product_price
    product_price = product_price[0] if product_price.is_a?(Array)
    landed_price = product_price.dig('BuyingPrice', 'LandedPrice')
    { selling_price_amount: landed_price.dig('Amount'),
      selling_price_currency: landed_price.dig('CurrencyCode')}
  end

  def sales_rank_info(product_info)
    sales_rank = product_info.dig('Product','SalesRankings','SalesRank')
    return {} unless sales_rank
    rank_info = sales_rank.is_a?(Array) ? sales_rank.dig(0) : sales_rank
    rank = rank_info.dig('Rank')
    { sales_rank: rank }
  end

  def small_image_url(product_attributes)
    url = product_attributes.dig('SmallImage', 'URL')
    url&.sub('_SL75_', '_SL125_')
  end
end
