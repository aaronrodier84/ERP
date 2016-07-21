class AddInbound24hrsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :inbound_qty, :integer
    add_column :products, :sold_last_24_hours, :integer
    add_column :products, :weeks_of_cover, :float
    add_column :products, :sellable_qty, :integer
  end
end
