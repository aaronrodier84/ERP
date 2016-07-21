class UpdateMetricColumns < ActiveRecord::Migration
  def change
    #remove_column :products, :inbound_qty
    #remove_column :products, :sold_last_24_hours
    #remove_column :products, :weeks_of_cover
    #remove_column :products, :sellable_qty

    add_column :products, :afn_fulfillable_quantity, :integer, :default => 0
    add_column :products, :afn_reserved_quantity, :integer, :default => 0
    add_column :products, :afn_inbound_working_quantity, :integer, :default => 0
    add_column :products, :afn_inbound_shipped_quantity, :integer, :default => 0

    #remove_column :products, :afn_fulfillable_quantity
    #remove_column :products, :afn_reserved_quantity
    #remove_column :products, :afn_inbound_working_quantity
    #remove_column :products, :afn_inbound_shipped_quantity
  end
end
