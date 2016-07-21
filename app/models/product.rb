# == Schema Information
#
# Table name: products
#
#  id                       :integer          not null, primary key
#  title                    :string
#  seller_sku               :string
#  asin                     :text
#  fnsku                    :string
#  size                     :string
#  list_price_amount        :string
#  list_price_currency      :string
#  total_supply_quantity    :integer
#  in_stock_supply_quantity :integer
#  small_image_url          :string
#  is_active                :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  inbound_qty              :float            default(0.0)
#  sold_last_24_hours       :float            default(0.0)
#  weeks_of_cover           :float            default(0.0)
#  sellable_qty             :float            default(0.0)
#  internal_title           :string
#  sales_rank               :integer
#  selling_price_amount     :float
#  selling_price_currency   :string
#  items_per_case           :integer          default(0), not null
#  production_buffer_days   :integer          default(35), not null
#  batch_min_quantity       :integer          default(0), not null
#  batch_max_quantity       :integer
#

class Product < ActiveRecord::Base
  has_many :product_zone_availabilities
  has_many :zones, through: :product_zone_availabilities
  has_many :product_inventories

  has_one :amazon_inventory

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false)}

  validates :production_buffer_days, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total_inventory
    [total_amazon_inventory, packed_inventory_quantity].sum
  end

  def urgency
    case days_of_cover
    when 0..10  then :red
    when 10..20 then :yellow
    else :green
    end
  end

  concerning :ZonesAvailable do
    # rubocop:disable Style/PredicateName
    def has_zones_available?
      product_zone_availabilities.count > 0
    end
    # rubocop:enable Style/PredicateName

    # rubocop:disable Style/PredicateName
    def has_zone?(zone)
      product_zone_availabilities.where(zone: zone).any?
    end
    # rubocop:enable Style/PredicateName

    # rubocop:disable Style/PredicateName
    def has_make_zone?
      has_zone?(Zone.make_zone)
    end
    # rubocop:enable Style/PredicateName

    # rubocop:disable Style/PredicateName
    def has_pack_zone?
      has_zone?(Zone.pack_zone)
    end
    # rubocop:enable Style/PredicateName

    # rubocop:disable Style/PredicateName
    def has_ship_zone?
      has_zone?(Zone.ship_zone)
    end
    # rubocop:enable Style/PredicateName
  end

  concerning :LocalInventories do
    def available_inventories
      Rails.cache.fetch self, expires: 1.hour do
        product_inventories.where(zone: zones)
      end
    end

    def make_product_inventory_record
      @make_product_inventory_record ||= product_inventories.find_by(zone: Zone.make_zone)
    end

    def pack_product_inventory_record
      @pack_product_inventory_record ||= product_inventories.find_by(zone: Zone.pack_zone)
    end

    def zone_inventory_quantity(zone)
      product_inventories.find_by(zone: zone)&.quantity || 0
    end

    def made_inventory_quantity
      zone_inventory_quantity(Zone.make_zone)
    end

    def packed_inventory_quantity
      zone_inventory_quantity(Zone.pack_zone)
    end

    def packed_inventory_quantity_in_days
      ProductAmount.new(packed_inventory_quantity).days(reserved)
    end

    def made_inventory_ingredients_cost
      make_product_inventory_record&.total_spent_ingredients_cost || 0
    end

    def packed_inventory_ingredients_cost
      pack_product_inventory_record&.total_spent_ingredients_cost || 0
    end
  end

  concerning :AmazonInventories do
    def reserved
      amazon_inventory&.reserved || 0
    end

    def inbound_working
      amazon_inventory&.inbound_working || 0
    end

    def inbound_shipped
      amazon_inventory&.inbound_shipped || 0
    end

    def fulfillable
      amazon_inventory&.fulfillable || 0
    end

    def total_amazon_inventory
      amazon_inventory&.total_amazon_inventory || 0
    end

    def days_of_cover
      amazon_inventory&.days_of_cover || 0
    end

    def days_to_cover
      amazon_inventory&.days_to_cover || 0
    end

    def amazon_coverage_ratio
      amazon_inventory&.coverage_ratio || 0
    end
  end

  concerning :FbaAllocations do
    included do
      has_many :fba_allocations
      has_many :fba_warehouses, through: :fba_allocations

      attr_accessor :to_ship_case_qty_override
      attr_accessor :to_ship_item_qty_override
    end

    def to_allocate_item_quantity
      to_ship_item_qty_override || ProductionPlan.new(self).to_ship
    end

    def to_allocate_case_quantity
      to_ship_case_qty_override || ProductionPlan.new(self).to_ship_in_cases
    end
  end

  concerning :Ingredients do
    included do
      has_many :ingredients, dependent: :destroy
    end

    # For pack zone, includes pack zone ingredients only.
    def ingredients_for_zone(zone)
      ingredients.for_zone(zone).includes(:material)
    end

    # For pack zone, includes pack and all previous zones' (make) ingredients.
    def ingredients_up_to_zone(zone)
      ingredients.up_to_zone(zone).includes(:material)
    end

    # For pack zone, includes pack zone ingredients only.
    def zone_ingredients_cost(zone)
      ingredients_for_zone(zone).map(&:cost).sum
    end

    # For pack zone, includes pack and all previous zones' (make) ingredients.
    def cumulative_zone_ingredients_cost(zone)
      ingredients_up_to_zone(zone).map(&:cost).sum
    end

    def total_ingredients_cost
      ingredients.map(&:cost).sum
    end

    # new_ingredient_attributes format:
    # [ {"material_id"=>"1", "quantity"=>"30"}, 
    #   {"material_id"=>"2", "quantity"=>"1"}, ... ]
    def replace_ingredients(new_ingredient_attributes)
      return true unless new_ingredient_attributes
      result = true

      ActiveRecord::Base.transaction do
        # A replacement of ingredients.destroy_all :
        Ingredient.where(id: ingredient_ids).delete_all  

        new_ingredient_attributes.each do |attributes_hash|
          ingredient = ingredients.build(attributes_hash)
          unless ingredient.save
            self.errors.add(:base, "Ingredient \"#{ingredient.material_name}\" cannot be saved: #{ingredient.errors.full_messages.first}")
            result = false
            raise ActiveRecord::Rollback
          end
        end
      end
      result
    end
  end
end
