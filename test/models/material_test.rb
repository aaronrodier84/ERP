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

require 'test_helper'

class MaterialTest < ActiveSupport::TestCase

  let(:material) { create :material }

  describe '#destroy' do
    it 'also destroys associated ingredients' do
      ingredient = create :ingredient, material: material

      assert_difference [->{Material.count}, ->{Ingredient.count}], -1 do
        material.destroy
      end
    end
  end
end
