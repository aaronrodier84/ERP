# frozen_string_literal: true
require 'test_helper'

class ProductsShipTabTest < ActionDispatch::IntegrationTest
  before { Zone.delete_all }
  let(:make_zone) { create :zone, :make }
  let(:pack_zone) { create :zone, :pack }
  let(:ship_zone) { create :zone, :ship }

  let(:lavender_oil) { create_product_in_zone ship_zone, items_per_case: 150, internal_title: "Lavender Oil" }
  let(:lemon_oil)    { create_product_in_zone ship_zone, items_per_case: 150, internal_title: "Lemon Oil" }

  let(:abc_warehouse) { create :fba_warehouse, name: "ABC" }
  let(:xyz_warehouse) { create :fba_warehouse, name: "XYZ" }
  let(:lavender_abc_allocation) { create :fba_allocation, product: lavender_oil, fba_warehouse: abc_warehouse }
  let(:lavender_xyz_allocation) { create :fba_allocation, product: lavender_oil, fba_warehouse: xyz_warehouse }
  let(:lemon_xyz_allocation)    { create :fba_allocation, product: lemon_oil,    fba_warehouse: xyz_warehouse }

  before do
    [make_zone, pack_zone, ship_zone,
     lavender_abc_allocation, lavender_xyz_allocation, lemon_xyz_allocation]

    add_user_to_all_zones(current_user)

    visit_products_ship_tab
    sleep 3 # waiting for tab full load - otherwise tests fail
  end

  describe 'FBA warehouse filter' do
    it 'filers by fba_allocation' do
      assert product_visible?(lavender_oil)
      assert product_visible?(lemon_oil)

      select_warehouse(xyz_warehouse.name)
      assert product_visible?(lavender_oil)
      assert product_visible?(lemon_oil)

      select_warehouse(abc_warehouse.name)
      assert product_visible?(lavender_oil)
      assert product_hidden?(lemon_oil)

      select_warehouse("All warehouses")
      assert product_visible?(lavender_oil)
      assert product_visible?(lemon_oil)
    end
  end

  describe 'Select All checkbox' do
    it 'only selects visible products' do
      select_warehouse(abc_warehouse.name)
      assert product_visible?(lavender_oil)
      assert product_hidden?(lemon_oil)

      select_all_products_checkbox

      select_warehouse("All warehouses")
      assert     product_cheked?(lavender_oil)
      assert_not product_cheked?(lemon_oil)
    end
  end

  describe 'case switcher' do
    it 'set to case by default' do
      assert case_view?
    end

    it 'switches between item/case view' do
      switch_to_item_view
      assert item_view?

      switch_to_case_view
      assert case_view?
    end
  end

  describe 'shipment name' do
    it 'is hidden when no warehouse selected' do
      assert page.has_no_selector?(".js-shipment-name")
    end

    it 'is auto populated upon warehouse select' do
      date_predix = Time.zone.today.strftime('%Y/%-m/%-d')

      select_warehouse(abc_warehouse.name)
      field_text = shipment_name_field.value
      expected_text = "#{date_predix} #{abc_warehouse.name}"
      assert_equal expected_text, field_text

      select_warehouse(xyz_warehouse.name)
      field_text = shipment_name_field.value
      expected_text = "#{date_predix} #{xyz_warehouse.name}"
      assert_equal expected_text, field_text
    end
  end

  protected

  def select_all_products_checkbox
    find(".js-select-all").set(true)
  end

  def unselect_all_products_checkbox
    find(".js-select-all").set(false)
  end

  def product_cheked?(product)
    product_tr(product).find("input[type='checkbox']").checked?
  end

  def select_warehouse(option_text)
    find(".js-warehouse").find(:option, option_text).select_option
  end

  def product_tr(product)
    find("tr[data-product-id='#{product.id}']")
  end

  def product_visible?(product)
    within 'table' do
      assert page.has_content? product.internal_title
    end
  end

  def product_hidden?(product)
    within 'table' do
      page.has_no_content? product.internal_title
    end
  end

  def switch_to_case_view
    find(".js-items-cases-toggler .js-cases").click
  end

  def switch_to_item_view
    find(".js-items-cases-toggler .js-items").click
  end

  def case_view?
    has_cases_in_header =
      within "table thead" do
        page.has_content? "Cases to ship"
      end

    has_cases_in_content =
      within "table tbody" do
        page.has_content? "ppc"
      end

    has_cases_in_header && has_cases_in_content
  end

  def item_view?
    has_items_in_header =
      within "table thead" do
        page.has_content? "Items to ship"
      end

    has_days_in_content =
      within "table tbody" do
        page.has_content? "days"
      end

    has_items_in_header && has_days_in_content
  end

  def shipment_name_field
    find(".js-shipment-name")
  end
end
