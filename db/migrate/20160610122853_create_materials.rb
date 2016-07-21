class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.belongs_to :zone, null: false
      t.string  :name, null: false
      t.string  :unit
      t.decimal :unit_price, null: false, default: 0
      
      t.timestamps

      t.index :zone_id
      t.foreign_key :zones
    end

    create_table :ingredients do |t|
      t.belongs_to :material, null: false
      t.belongs_to :product, null: false
      t.integer :quantity, null: false, default: 1
      
      t.timestamps

      t.index [:product_id, :material_id], unique: true
      t.index :material_id
      t.foreign_key :materials
      t.foreign_key :products
    end
  end
end
