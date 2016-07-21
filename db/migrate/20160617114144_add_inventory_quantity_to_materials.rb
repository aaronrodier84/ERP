class AddInventoryQuantityToMaterials < ActiveRecord::Migration
  def change
    change_table :materials do |t|
      t.integer :inventory_quantity, null: false, default: 0
    end
  end
end
