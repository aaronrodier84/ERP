require 'test_helper'

class ProductConcerningIngredientsTest < ActiveSupport::TestCase
  let(:product) { create :product }

  describe '#total_ingredients_cost' do
    it 'returns total ingredient cost' do
      material1   = create :material, unit_price: 2.10
      ingredient1 = create :ingredient, product: product, material: material1, quantity: 5
      material2   = create :material, unit_price: 0.49
      ingredient2 = create :ingredient, product: product, material: material2, quantity: 1
      assert_equal 10.99, product.total_ingredients_cost
    end

    it 'returns 0 when there is no ingredients' do
      assert product.ingredients.empty?
      assert_equal 0, product.total_ingredients_cost
    end

    it 'works fine on default values and nils' do
      ingredient = create :ingredient, product: product
      assert product.ingredients.any?
      assert product.total_ingredients_cost
    end
  end

  describe '#zone_ingredients_cost' do
    let(:zone) { create :zone }

    it 'returns ingredient cost spendings on single unit of this product in this zone' do
      material1   = create :material, zone: zone, unit_price: 2.10
      ingredient1 = create :ingredient, product: product, material: material1, quantity: 5
      material2   = create :material, zone: zone, unit_price: 0.49
      ingredient2 = create :ingredient, product: product, material: material2, quantity: 1
      
      irrelevant_zone = create :zone
      irrelevant_material   = create :material, zone: irrelevant_zone, unit_price: 1000
      irrelevant_ingredient = create :ingredient, product: product, material: irrelevant_material, quantity: 1
      assert product.ingredients.include?(irrelevant_ingredient)

      assert_equal 2.10 * 5 + 0.49, product.zone_ingredients_cost(zone)
    end

    it 'returns 0 when there is no ingredients' do
      assert product.ingredients.empty?
      assert_equal 0, product.zone_ingredients_cost(zone)
    end
  end

  describe '#cumulative_zone_ingredients_cost' do
    let(:product) { create :product }
    let(:make_zone) { create :zone, :make }
    let(:pack_zone) { create :zone, :pack }
    let(:ship_zone) { create :zone, :ship }

    it 'returns ingredient cost spendings to produce single unit of this product up to this zone' do
      make_material = create :material, zone: make_zone, unit_price: 3.09
      create :ingredient, product: product, material: make_material, quantity: 5

      pack_material_first = create :material, zone: pack_zone, unit_price: 1.99
      create :ingredient, product: product, material: pack_material_first, quantity: 4

      pack_material_second = create :material, zone: pack_zone, unit_price: 0.85
      create :ingredient, product: product, material: pack_material_second, quantity: 2

      ship_material = create :material, zone: ship_zone, unit_price: 1.11
      create :ingredient, product: product, material: ship_material, quantity: 1

      assert_equal 3.09 * 5, product.cumulative_zone_ingredients_cost(make_zone)
      assert_equal 3.09 * 5 + 1.99 * 4 + 0.85 * 2, product.cumulative_zone_ingredients_cost(pack_zone)
      assert_equal 3.09 * 5 + 1.99 * 4 + 0.85 * 2 + 1.11, product.cumulative_zone_ingredients_cost(ship_zone)
    end

    it 'returns 0 when there is no ingredients' do
      assert product.ingredients.empty?
      assert_equal 0, product.cumulative_zone_ingredients_cost(pack_zone)
    end
  end

  describe '#replace_ingredients' do
    let(:material1) { create :material, name: "Cap" }
    let(:material2) { create :material }

    it 'creates product ingredients from hash and returns true' do
      hash = [ {material_id: material1.id, quantity: 30}, 
               {material_id: material2.id, quantity: 1 } ]
      
      assert product.ingredients.empty?
      assert_difference ->{Ingredient.count}, 2 do
        assert product.replace_ingredients(hash)
      end

      ingredient1 = product.ingredients.order(:id).first
      ingredient2 = product.ingredients.order(:id).second
      assert_equal 30, ingredient1.quantity
      assert_equal material1, ingredient1.material
      assert_equal 1, ingredient2.quantity
      assert_equal material2, ingredient2.material
    end

    it 'works fine with string-value hashes' do
      hash = [ {"material_id"=> material1.id.to_s, "quantity"=>"29"} ]

      assert_difference ->{Ingredient.count}, 1 do
        assert product.replace_ingredients(hash)
      end

      ingredient = product.ingredients.first
      assert_equal 29, ingredient.quantity
      assert_equal material1, ingredient.material
    end

    it 'replaces previous ingredients' do
      create :ingredient, product: product
      assert_equal 1, product.ingredients.count

      hash = [ {material_id: material2.id, quantity: 1111} ]
      assert product.replace_ingredients(hash)
      assert_equal 1, product.ingredients.count

      ingredient = product.ingredients.first
      assert_equal 1111, ingredient.quantity
      assert_equal material2, ingredient.material
    end

    it 'returns false + error message in case of duplicated materials' do
      hash = [ {material_id: material1.id, quantity: 30}, 
               {material_id: material1.id, quantity: 1 } ]
      
      assert_no_difference ->{Ingredient.count} do
        refute product.replace_ingredients(hash)
      end

      assert_equal "Ingredient \"Cap\" cannot be saved: Material is a duplicate", product.errors.full_messages.first
    end

    it 'in case of invalid data, leaves previous ingredients without changes' do
      # assuming the product aleady has an ingredient
      ingredient = create :ingredient, product: product
      assert_equal 1, product.ingredients.count

      hash = [ {material_id: material1.id, quantity: 30}, 
               {material_id: material1.id, quantity: 1 } ]
      
      assert_no_difference ->{Ingredient.count} do
        refute product.replace_ingredients(hash)
      end

      # check the ingredient remains there (not removed)
      product.ingredients.reload
      assert_equal 1, product.ingredients.count
      assert_equal ingredient.id, product.ingredients.first.id
    end
  end

end
