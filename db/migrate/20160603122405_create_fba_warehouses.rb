class CreateFbaWarehouses < ActiveRecord::Migration
  def change
    create_table :fba_warehouses do |t|
      t.string :name, null: false
      t.timestamps

      t.index :name
    end

    create_table :fba_allocations do |t|
      t.belongs_to :fba_warehouse, null: false
      t.belongs_to :product, null: false
      t.integer :quantity, null: false

      t.index [:product_id, :fba_warehouse_id], unique: true
      t.index :fba_warehouse_id
    end
  end
end
