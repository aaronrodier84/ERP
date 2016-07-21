# == Schema Information
#
# Table name: ingredients
#
#  id          :integer          not null, primary key
#  material_id :integer          not null
#  product_id  :integer          not null
#  quantity    :integer          default(1), not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Foreign Keys
#
#  fk_rails_7ab80c2b55  (material_id => materials.id)
#  fk_rails_db974bf3ef  (product_id => products.id)
#

require 'test_helper'

class IngredientTest < ActiveSupport::TestCase

  describe '#cost' do
    it 'returns the cost of the ingredient' do
      material = create :material, unit_price: 3.01
      ingredient = create :ingredient, material: material, quantity: 9
      assert_equal 27.09, ingredient.cost
    end

    it 'works fine with default values and nils' do
      ingredient = create :ingredient
      assert ingredient.cost
    end
  end

  describe '.for_zone' do
    it 'returns ingredients with materials related to the zone' do
      make_zone = create :zone, :make
      make_ingredient = create_ingredient_in_zone(make_zone)

      pack_zone = create :zone, :pack
      pack_ingredient = create_ingredient_in_zone(pack_zone)

      make_ingredients = Ingredient.for_zone(make_zone)
      assert make_ingredients.include?(make_ingredient)
      refute make_ingredients.include?(pack_ingredient)

      pack_ingredients = Ingredient.for_zone(pack_zone)
      assert pack_ingredients.include?(pack_ingredient)
      refute pack_ingredients.include?(make_ingredient)
    end
  end

  describe '.up_to_zone' do
    it 'returns ingredients with materials related to the zone specified, and all zones before the specified' do
      make_zone = create :zone, :make
      make_ingredient = create_ingredient_in_zone(make_zone)

      pack_zone = create :zone, :pack
      pack_ingredient = create_ingredient_in_zone(pack_zone)

      ship_zone = create :zone, :ship
      ship_ingredient = create_ingredient_in_zone(ship_zone)

      make_ingredients = Ingredient.up_to_zone(make_zone)
      assert make_ingredients.include?(make_ingredient)
      refute make_ingredients.include?(pack_ingredient)
      refute make_ingredients.include?(ship_ingredient)

      pack_ingredients = Ingredient.up_to_zone(pack_zone)
      assert pack_ingredients.include?(make_ingredient)
      assert pack_ingredients.include?(pack_ingredient)
      refute pack_ingredients.include?(ship_ingredient)

      ship_ingredients = Ingredient.up_to_zone(ship_zone)
      assert ship_ingredients.include?(make_ingredient)
      assert ship_ingredients.include?(pack_ingredient)
      assert ship_ingredients.include?(ship_ingredient)
    end
  end
end
