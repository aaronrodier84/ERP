class AddManufacturingLog < ActiveRecord::Migration
  def change
    create_table :manufacturing_logs do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :quantity
      t.datetime :date
      t.text :notes
 
      t.timestamps null: false
    end
  end
end
