class AddProdBufferToZones < ActiveRecord::Migration
  def change
    change_table :zones do |t|
      t.integer :production_buffer_days, null: false, default: 30
    end
  end
end
