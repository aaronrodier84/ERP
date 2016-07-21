class ProductsPresenter
  attr_reader :products, :zone

  def initialize(products, zone=nil)
    @products = products
    @zone = zone
  end

  def product_presenters
    products.map {|product| ProductPresenter.new(product) }
  end

  def zone_id
    zone&.id
  end

  def ship_tab?
    zone&.ship?
  end

  def warehouses
    FbaWarehouse.all
  end
end
