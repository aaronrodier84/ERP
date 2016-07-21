class IngredientPresenter
  attr_reader :ingredient

  delegate :material_zone, :material_name, :cost, to: :ingredient

  def initialize(ingredient)
    @ingredient = ingredient
  end

  def quantity_with_unit
    "#{ingredient.quantity}&nbsp;#{ingredient.material_unit}".html_safe
  end

end
