class SetDefaultsForMetrics < ActiveRecord::Migration
  def change
    change_column :products, :weeks_of_cover, :float, :default => 0.0
    change_column :products, :sold_last_24_hours, :float, :default => 0.0
    change_column :products, :inbound_qty, :float, :default => 0.0
    change_column :products, :sellable_qty, :float, :default => 0.0
  end
end
