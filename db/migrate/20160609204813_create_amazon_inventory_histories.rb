class CreateAmazonInventoryHistories < ActiveRecord::Migration
  def change
    create_table :amazon_inventory_histories do |t|
      t.integer :fulfillable
      t.integer :reserved
      t.integer :inbound_working
      t.integer :inbound_shipped
      t.datetime :reported_at
      t.references :amazon_inventory

      t.index :amazon_inventory_id
      t.index :reported_at
      t.timestamps null: false
    end
  end
end
