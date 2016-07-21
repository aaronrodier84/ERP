class AddProductionOrderToZone < ActiveRecord::Migration
  def change
    add_column :zones, :production_order, :integer
  end
end
