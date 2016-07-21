class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.integer :product_id
      t.integer :quantity
      t.text :notes
 
      t.timestamps null: false
    end
  end
end
