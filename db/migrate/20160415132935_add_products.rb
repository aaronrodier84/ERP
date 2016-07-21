class AddProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.string :seller_sku
      t.text :asin
      t.string :fnsku
      t.string :size
      t.string :list_price_amount
      t.string :list_price_currency
      t.integer :total_supply_quantity
      t.integer :in_stock_supply_quantity
      t.string :small_image_url
			t.boolean :is_active, default: true
 
      t.timestamps null: false
    end
  end
end
