class CreateAmazonInventory < ActiveRecord::Migration
  def change
    create_table :amazon_inventories do |t|
      t.integer :fulfillable, default: 0
      t.integer :reserved, default: 0
      t.integer :inbound_working, default: 0
      t.integer :inbound_shipped, default: 0
      t.references :product

      t.index :product_id
    end
  end
end
