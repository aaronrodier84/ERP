# frozen_string_literal: true
require 'test_helper'

class IngredientsEditTest < ActionDispatch::IntegrationTest
  let(:product) { create :product }
  let(:lavender_oil) { create :material, name: "Lavender Oil", unit: "ML" }
  let(:lemon_oil)    { create :material, name: "Lemon Oil", unit: "Kg" }
  let(:empty_bottle) { create :material, name: "Empty Bottle", unit: "Each" }

  it 'allows to add ingredients' do
    [lavender_oil, lemon_oil, empty_bottle]
    visit edit_ingredients_product_path(product)

    click_add_ingredient
    last_ingredient_material_select.find(:option, empty_bottle.name).select_option
    assert_equal "Each", last_ingredient_unit_of_measure

    click_add_ingredient
    last_ingredient_material_select.find(:option, lemon_oil.name).select_option
    last_ingredient_quantity_input.set(2)
    assert_equal "Kg", last_ingredient_unit_of_measure
    last_ingredient_delete_button.click # add and delete right away

    click_add_ingredient
    last_ingredient_material_select.find(:option, lavender_oil.name).select_option
    assert_equal "ML", last_ingredient_unit_of_measure
    last_ingredient_quantity_input.set(10)

    assert_difference -> { Ingredient.count }, 2 do
      click_on 'Save'
      assert page.has_content? "Ingredients were successfully saved"
    end

    check_ingredients(product, lavender_oil.id => 10, empty_bottle.id => 1)
  end

  it 'allows to remove ingredients' do
    create :ingredient, product_id: product.id, material_id: lavender_oil.id, quantity: 1
    create :ingredient, product_id: product.id, material_id: lemon_oil.id, quantity: 1
    check_ingredients(product.reload, lavender_oil.id => 1, lemon_oil.id => 1)

    visit edit_ingredients_product_path(product)
    last_ingredient_delete_button.click # add and delete right away
    last_ingredient_delete_button.click # add and delete right away

    assert_difference -> { Ingredient.count }, -2 do
      click_on 'Save'
      assert page.has_content? "Ingredients were successfully saved"
    end

    check_ingredients(product, {})
  end

  protected

  def click_add_ingredient
    find(".js-add-ingredient").click
  end

  def last_ingredient_material_select
    last_ingredient_form_tr.find("select.js-material")
  end

  def last_ingredient_quantity_input
    last_ingredient_form_tr.find("input.js-quantity")
  end

  def last_ingredient_unit_of_measure
    last_ingredient_form_tr.find(".js-unit").text
  end

  def last_ingredient_delete_button
    last_ingredient_form_tr.find(".js-remove")
  end

  def last_ingredient_form_tr
    all(".js-edit-product-ingredients table tbody tr").last
  end

  # ingredients_hash: { material_id => quantity, ...}
  def check_ingredients(product, ingredients_hash)
    product_ingredients = product.ingredients
    ingredients_hash.each do |material_id, quantity|
      ingredient = product_ingredients.find_by(material_id: material_id)
      assert_equal quantity, ingredient.quantity
    end
    assert_equal product_ingredients.count, ingredients_hash.count
  end
end
