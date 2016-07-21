class AddDefaultUserZone < ActiveRecord::Migration
  def change
    add_column :users, :default_zone, :integer
  end
end
