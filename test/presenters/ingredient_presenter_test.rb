require 'test_helper'

class IngredientPresenterTest < ActiveSupport::TestCase

  describe '#quantity_with_unit' do
    let(:material)   { create :material, unit: 'ml' }
    let(:ingredient) { build :ingredient, material: material, quantity: 50 }

    it 'returns quantity of material with a unit of measure' do
      presenter = described_class.new ingredient
      assert_equal "50&nbsp;ml", presenter.quantity_with_unit
    end
  end
end
