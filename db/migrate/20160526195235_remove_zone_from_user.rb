class RemoveZoneFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :zone_id, :integer
  end
end
