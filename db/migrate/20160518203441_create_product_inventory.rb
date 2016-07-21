class CreateProductInventory < ActiveRecord::Migration
  def change
    create_table :product_inventories do |t|
      t.integer :quantity, default: 0
      t.references :product
      t.references :zone
    end
  end
end
