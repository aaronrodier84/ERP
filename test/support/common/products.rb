# frozen_string_literal: true

def create_product_in_zone(zone, attrs = {})
  create_product_in_zones([zone], attrs)
end

def create_product_in_zones(zones, attrs = {})
  product = create(:product, :active, attrs)
  product.zones += zones
  product.save!
  product
end
