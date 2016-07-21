# == Schema Information
#
# Table name: zones
#
#  id               :integer          not null, primary key
#  name             :string
#  production_order :integer
#

class Zone < ActiveRecord::Base
  has_many :product_zone_availabilities
  has_many :products, through: :product_zone_availabilities
  has_many :product_inventories
  has_many :materials

  default_scope { order(:name) }
  scope :visible, -> { where(name: ['Make', 'Pack'])}
  scope :ordered, -> { order(production_order: :asc)}

  after_update :expire_cache

  def slug
    name.downcase
  end

  def active_products
    products.active.includes(:amazon_inventory).sort_by(&:days_of_cover)
  end

  def inactive_products
    products.inactive.includes(:amazon_inventory)
  end

  def self.default_zone
    Zone.make_zone
  end

  def self.make_zone
    Rails.cache.fetch 'zones/make_zone', expires: 1.hour do
      Zone.find_by name: 'Make'
    end
  end

  def self.pack_zone
    Rails.cache.fetch 'zones/pack_zone', expires: 1.hour do
      Zone.find_by name: 'Pack'
    end
  end

  def self.ship_zone
    Rails.cache.fetch 'zones/ship_zone', expires: 1.hour do
      Zone.find_by name: 'Ship'
    end
  end

  def self.fetch_or_default(zone_id)
    find_by(id: zone_id) || default_zone
  end

  def make?
    name == 'Make'
  end

  def pack?
    name == 'Pack'
  end

  def ship?
    name == 'Ship'
  end

  protected

  def expire_cache
    Rails.cache.delete("zones/#{slug}_zone")
  end
end
