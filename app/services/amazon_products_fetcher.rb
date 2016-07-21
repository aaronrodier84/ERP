class AmazonProductsFetcher
  include WithThrottling
  include Logging

  #http://www.amazon.com/gp/help/customer/display.html/?nodeId=200680710
  #http://docs.developer.amazonservices.com/en_US/reports/Reports_ReportType.html#ReportTypeCategories__FBAReports

  # Because reports take a variable amount of time to be generated, 
  # we request a report, then just get the latest one. If we run this each hour we should be fine.
  
  def self.build
    products_api = Amazon::ProductsApi.build Setting.instance.amazon_config
    parser = AmazonProductParser.new
    create_product = Products::CreateProduct.new
    update_product = Products::UpdateProduct.new
    product_actions = { create: create_product, update: update_product }
    new(products_api, parser, product_actions)
  end

  def initialize(products_api, parser, product_actions = {})
    @products_api = products_api
    @parser = parser
    @create_product_action = product_actions.dig(:create)
    @update_product_action = product_actions.dig(:update)
  end

  def run(date)
    inventories = products_api.fetch_inventories(date)
    log "Parsing fetched products"
    parsed_products = parse_products(inventories)
    log "Saving parsed products"
    parsed_products.each { |product_data| persist_product(product_data)}
    log "Products updated"
  end

  private

  def parse_products(inventories)
    product_inventory_infos = inventories.map do |inventory|
      supply_list = inventory['InventorySupplyList']
      supply_list['member']
    end.flatten
    
    log "Getting additional info for products, products to fetch: #{product_inventory_infos.size}"

    with_additional_info = product_inventory_infos.map do |inventory_info|
      throttle 30, per: :minute do
        asin = inventory_info['ASIN']
        product_info = products_api.fetch_product_info asin
        product_price = products_api.fetch_product_price asin
        OpenStruct.new inventory_info: inventory_info, product_info: product_info.to_h.deep_merge(product_price)
      end
    end

    log "Parsing products info"
    
    with_additional_info.map { |product| parse_product_info(product)}.compact
  end

  def persist_product(product_info)
    product = Product.find_or_initialize_by fnsku: product_info.fnsku
    if product.persisted?
      update_product_action.call product, product_info.data
    end
  end

  def parse_product_info(product)
    product_info = product.product_info
    inventory_info = product.inventory_info

    parsed_product_data = parser.parse(inventory_info, product_info)

    OpenStruct.new fnsku: parser.fnsku(inventory_info), data: parsed_product_data
  end

  private
  attr_reader :products_api, :parser, :create_product_action, :update_product_action
end
