# == Schema Information
#
# Table name: materials
#
#  id                 :integer          not null, primary key
#  zone_id            :integer          not null
#  name               :string           not null
#  unit               :string
#  unit_price         :decimal(, )      default(0.0), not null
#  created_at         :datetime
#  updated_at         :datetime
#  inventory_quantity :integer          default(0), not null
#
# Foreign Keys
#
#  fk_rails_8c44ac1fea  (zone_id => zones.id)
#

class Material < ActiveRecord::Base
  belongs_to :zone
  has_many :ingredients, dependent: :destroy
  has_many :products, through: :ingredients

  scope :ordered_by_id, -> { order(:id) }

  validates :zone_id, :name, presence: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :inventory_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

end
