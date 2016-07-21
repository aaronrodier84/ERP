class UseZoneTable < ActiveRecord::Migration
  def change
    remove_column :users, :default_zone
    add_column :users, :zone_id, :integer
  end
end
