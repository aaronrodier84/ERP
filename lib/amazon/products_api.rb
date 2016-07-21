module Amazon
  class ProductsApi
    include WithThrottling
    include Logging

    def self.build(config = {})
      inventory_client = MWS.fulfillment_inventory(config)
		  product_client = MWS.products(config)
		  new(inventory_client, product_client, { marketplace_id: config[:primary_marketplace_id]})
    end

    def initialize(inventory_client, product_client, options = {})
      @inventory_client = inventory_client
      @product_client = product_client
      @marketplace_id = options.fetch(:marketplace_id, '')
    end

    def fetch_inventories(date)
      log "Fetching inventories from Amazon"
      request_options = { response_group: 'Detailed', query_start_date_time: date }
      log "Requested inventory supply for #{date}"
      inventory = inventory_client.list_inventory_supply(request_options).parse
      inventories = [inventory]
      while inventory['NextToken'] do
        throttle 30, per: :second do
          token = inventory['NextToken']
          log "Requested following inventory supply"
          inventory = inventory_client.list_inventory_supply_by_next_token(token).parse 
          inventories << inventory
        end
      end
      log "Finished fetching inventories from Amazon"
      inventories
    end

    def fetch_product_info(asin)
      return nil unless asin
      options = { marketplace_id: marketplace_id }
      log "Getting product info for #{asin}"
      log product_client
      product_info = product_client.get_matching_product(asin, options)
      product_info.parse
    end

    def fetch_product_price(asin)
      return nil unless asin
      options = { marketplace_id: marketplace_id}
      log "Getting product price for #{asin}"
      product_price = product_client.get_my_price_for_asin asin, options
      product_price.parse
    end

    private
    attr_reader :inventory_client, :product_client, :logger, :marketplace_id
  end
end

