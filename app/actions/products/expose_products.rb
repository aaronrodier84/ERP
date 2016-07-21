module Products
  class ExposeProducts

    def expose_to_all_zones(product)
      return if product.has_zones_available?
      product_zones = Zone.all.map do
        |zone| ProductZoneAvailability.find_or_initialize_by product: product, zone: zone
      end
      ProductZoneAvailability.import product_zones
    end
  end
end
