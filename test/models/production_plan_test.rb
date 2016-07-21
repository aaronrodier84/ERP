# frozen_string_literal: true
require 'test_helper'

class ProductionPlanTest < ActiveSupport::TestCase
  describe "#zone_demand" do
    describe "when ship zone is passed" do
      it "returns #ship_demand" do
        ship_zone = create :zone, :ship
        product = create_product_in_zone(ship_zone)
        plan = described_class.new(product)
        plan.stubs(:ship_demand).returns(1111)
        assert_equal 1111, plan.zone_demand(ship_zone)
      end
    end

    describe "when pack or make zone is passed" do
      # tested in "#make_demand" and "#pack_demand" specs
      # (tested that those methods directly call #zone_demand, and tested the return values)
    end
  end

  describe '#ship_demand' do
    it 'is how many items we ideally want to ship' do
      product = stub(total_amazon_inventory: 500, zones: [])
      plan = described_class.new(product)
      plan.stubs(:total_demand).returns(2000)
      assert_equal 1500, plan.ship_demand
    end

    describe "when FBA is overstocked" do
      it 'is 0 rather then negative' do
        product = stub(total_amazon_inventory: 500, zones: [])
        plan = described_class.new(product)
        plan.stubs(:total_demand).returns(70)
        assert_equal 0, plan.ship_demand
      end
    end

    describe "when there is no inventory left on Amazon" do
      let(:product) { stub(total_amazon_inventory: 0, items_per_case: 90, zones: []) }

      it "suggests to ship at least 1 case" do
        plan = described_class.new(product)
        plan.stubs(:total_demand).returns(20)
        assert_equal 90, plan.ship_demand
      end

      it "suggests to ship more than 1 case if demanded" do
        plan = described_class.new(product)
        plan.stubs(:total_demand).returns(200)
        assert_equal 200, plan.ship_demand
      end
    end
  end

  describe "#pack_demand" do
    let(:pack_zone) { create :zone, :pack }
    let(:ship_zone) { create :zone, :ship }
    let(:product) { create_product_in_zones([pack_zone, ship_zone]) }
    let(:pack_product_inventory) do
      create :product_inventory, zone: pack_zone, product: product, quantity: 1000
    end
    let(:plan) { described_class.new(product) }

    before do
      pack_product_inventory # touching so that it's lazy loaded
      assert_equal 1000, product.packed_inventory_quantity
    end

    it "directly returns #zone_demand for pack zone" do
      plan.stubs(:zone_demand).with(pack_zone).returns(2222)
      assert_equal 2222, plan.pack_demand
    end

    describe "when there is more than enough of packed product inventory" do
      it "returns 0 rather than negative" do
        # making plan to return 300 as ship_demand;
        plan.stubs(:total_demand).returns(300)
        assert_equal 300, plan.ship_demand
        # checking pack_demand is 0 (300 demanded, 1000 packed, nothing to pack)
        assert_equal 0, plan.pack_demand

        # the same check for 1000 as ship_demand
        # (1000 demanded, 1000 packed, nothing to pack)
        plan.stubs(:total_demand).returns(1000) # 1000 == 1000
        assert_equal 1000, plan.ship_demand
        assert_equal 0, plan.pack_demand
      end
    end

    describe "when there is not enough packed product inventory" do
      it "returns the difference" do
        # making plan to return 1600 as ship_demand;
        plan.stubs(:total_demand).returns(1600)
        assert_equal 1600, plan.ship_demand
        # 1600 demanded, 1000 packed, need to pack 600
        assert_equal 1600 - 1000, plan.pack_demand
      end
    end
  end

  describe "#make_demand" do
    let(:make_zone) { create :zone, :make }
    let(:pack_zone) { create :zone, :pack }
    let(:ship_zone) { create :zone, :ship }
    let(:product) { create_product_in_zones([make_zone, pack_zone, ship_zone]) }
    let(:make_product_inventory) do
      create :product_inventory, zone: make_zone, product: product, quantity: 1000
    end
    let(:plan) { described_class.new(product) }

    before do
      make_product_inventory # touching so that it's lazy loaded
      assert_equal 1000, product.made_inventory_quantity
    end

    it "directly returns #zone_demand for make zone" do
      plan.stubs(:zone_demand).with(make_zone).returns(2222)
      assert_equal 2222, plan.make_demand
    end

    describe "when there is more than enough of made product inventory" do
      it "returns 0 rather than negative" do
        # making plan to return 300 as ship_demand;
        plan.stubs(:total_demand).returns(300)
        assert_equal 300, plan.pack_demand
        # checking make_demand is 0 (300 demanded, 1000 made, nothing to make)
        assert_equal 0, plan.make_demand

        # the same check for 1000 as pack_demand
        # (1000 demanded, 1000 made, nothing to make)
        plan.stubs(:total_demand).returns(1000) # 1000 == 1000
        assert_equal 1000, plan.pack_demand
        assert_equal 0, plan.make_demand
      end
    end

    describe "when there is not enough made product inventory" do
      it "returns the difference" do
        # making plan to return 1600 as pack_demand;
        plan.stubs(:total_demand).returns(1600)
        assert_equal 1600, plan.pack_demand
        # 1600 demanded, 1000 made, need to make 600
        assert_equal 1600 - 1000, plan.make_demand
      end
    end
  end

  describe "#zone_provision" do
    it "says how much product can be produced from the current inventory" do
      make_zone = create :zone, :make
      pack_zone = create :zone, :pack
      ship_zone = create :zone, :ship
      product = create_product_in_zones([make_zone, pack_zone, ship_zone])
      create :product_inventory, zone: make_zone, product: product, quantity: 1000
      create :product_inventory, zone: pack_zone, product: product, quantity: 2000
      plan = described_class.new(product)

      assert_equal Float::INFINITY, plan.zone_provision(make_zone)
      assert_equal 1000, plan.zone_provision(pack_zone)
      assert_equal 2000, plan.zone_provision(ship_zone)
    end

    describe "when there is no make zone" do
      it "works as usual" do
        pack_zone = create :zone, :pack
        ship_zone = create :zone, :ship
        product = create_product_in_zones([pack_zone, ship_zone])
        create :product_inventory, zone: pack_zone, product: product, quantity: 2000
        plan = described_class.new(product)

        assert_equal Float::INFINITY, plan.zone_provision(pack_zone)
        assert_equal 2000, plan.zone_provision(ship_zone)
      end
    end
  end

  describe "#to_cover_in_zone" do
    it "says how much of demanded product can be produced from the current inventory" do
      ship_zone = create :zone, :ship
      pack_zone = create :zone, :pack
      product = create_product_in_zones([pack_zone, ship_zone])

      # Provision 2000 items of packed product
      create :product_inventory, zone: pack_zone, product: product, quantity: 2000

      plan = described_class.new(product)

      # Demand 2500 items to Amazon
      plan.stubs(:total_demand).returns(2500)
      assert_equal 2500, plan.ship_demand
      assert_equal 500,  plan.pack_demand

      # Check how many we can cover now in each zone
      assert_equal 2000, plan.to_cover_in_zone(ship_zone)
      assert_equal  500, plan.to_cover_in_zone(pack_zone)
    end
  end

  describe '#to_make' do
    it 'directly calls #to_cover_in_zone' do
      make_zone = create :zone, :make
      plan = described_class.new(stub(zones: []))
      plan.stubs(:to_cover_in_zone).with(make_zone).returns(3333)
      assert_equal 3333, plan.to_make
    end
  end

  describe '#to_pack' do
    it 'directly calls #to_cover_in_zone' do
      pack_zone = create :zone, :pack
      plan = described_class.new(stub(zones: []))
      plan.stubs(:to_cover_in_zone).with(pack_zone).returns(4444)
      assert_equal 4444, plan.to_pack
    end
  end

  describe '#to_ship' do
    it 'directly calls #to_cover_in_zone' do
      ship_zone = create :zone, :ship
      plan = described_class.new(stub(zones: []))
      plan.stubs(:to_cover_in_zone).with(ship_zone).returns(5555)
      assert_equal 5555, plan.to_ship
    end
  end

  describe "#to_ship_in_cases" do
    it 'converts to_ship to integer cases' do
      product = stub(items_per_case: 3, zones: [])
      plan = described_class.new(product)
      plan.stubs(:to_ship).returns(100)
      assert_equal 33, plan.to_ship_in_cases
    end
  end
end
