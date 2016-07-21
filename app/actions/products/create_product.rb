module Products
  class CreateProduct

    def initialize(products_exposer = ExposeProducts.new)
      @products_exposer = products_exposer
    end

    def call(params)
      product = Product.new params
      result = save_product product

      if result.success?
        run_post_creation_actions(product)  
      end
      result
    end

    private

    attr_reader :products_exposer

    def save_product(product)
      if product.save
        StoreResult.new entity: product, success: true
      else
        StoreResult.new entity: product, success: false, errors: product.errors
      end
    end

    def run_post_creation_actions(product)
      products_exposer.expose_to_all_zones(product)
      create_product_inventories(product)
      create_amazon_inventory(product)
    end

    def create_product_inventories(product)
      inventories = Zone.all.map { |zone| ProductInventory.find_or_initialize_by product: product, zone: zone }.reject(&:persisted?)
      ProductInventory.import inventories
    end

    def create_amazon_inventory(product)
      AmazonInventory.find_or_create_by product: product
    end
  end
end
