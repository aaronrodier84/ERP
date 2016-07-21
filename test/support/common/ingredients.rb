# frozen_string_literal: true
def create_ingredient_in_zone(zone, ingredient_attrs = {})
  material = create :material, zone: zone
  create :ingredient, ingredient_attrs.merge(material: material)
end
