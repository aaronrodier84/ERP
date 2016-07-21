# frozen_string_literal: true
require 'test_helper'

class ProductInventoryPresenterTest < ActiveSupport::TestCase
  describe "#made_plus_packed_inventory_total" do
    it "it sums product's made and packed inventory quantity" do
      product = stub(made_inventory_quantity: 111, packed_inventory_quantity: 222)
      presenter = described_class.new(product)
      assert_equal 111 + 222, presenter.made_plus_packed_inventory_total
    end
  end

  describe "#made_plus_packed_cost_total" do
    it "it sums product's made and packed inventory costs" do
      product = stub(made_inventory_ingredients_cost: 11, packed_inventory_ingredients_cost: 22)
      presenter = described_class.new(product)
      assert_equal 11 + 22, presenter.made_plus_packed_cost_total
    end
  end

  describe "#fba_total" do
    it "it sums product's inbound-shipped fulfillable inventory quantities" do
      product = stub(inbound_shipped: 100, fulfillable: 22)
      presenter = described_class.new(product)
      assert_equal 100 + 22, presenter.fba_total
    end
  end

  describe "#fba_cost_total" do
    it "it sums product's inbound-shipped fulfillable inventory costs" do
      presenter = described_class.new(Object.new)
      presenter.stubs(:inbound_shipped_cost_total).returns(100)
      presenter.stubs(:fulfillable_cost_total).returns(200)
      assert_equal 100 + 200, presenter.fba_cost_total
    end
  end

  describe "#days_of_cover_hint" do
    it "explains how days_of_cover is calculated" do
      product = stub(inbound_shipped: 100, fulfillable: 20, reserved: 30)
      presenter = described_class.new(product)
      assert_equal "= 120 / 30".gsub(' ', '&nbsp;'), presenter.days_of_cover_hint
    end
  end

  describe '#inbound_shipped_cost_total' do
    let(:product) { create :product, selling_price_amount: 7.99 }

    it 'calculates total selling price of all inbound shipped items' do
      product.stubs(:inbound_shipped).returns(100)
      assert_equal 799, described_class.new(product).inbound_shipped_cost_total
    end

    describe 'when product selling price is undefined' do
      let(:product) { create :product, selling_price_amount: nil }

      it 'returns 0' do
        assert_equal 0, described_class.new(product).inbound_shipped_cost_total
      end
    end
  end

  describe '#fulfillable_cost_total' do
    let(:product) { create :product, selling_price_amount: 7.99 }

    it 'calculates total selling price of all inbound shipped items' do
      product.stubs(:fulfillable).returns(100)
      assert_equal 799, described_class.new(product).fulfillable_cost_total
    end

    describe 'when product selling price is undefined' do
      let(:product) { create :product, selling_price_amount: nil }

      it 'returns 0' do
        assert_equal 0, described_class.new(product).fulfillable_cost_total
      end
    end
  end
end
