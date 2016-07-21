class CreateUserZone < ActiveRecord::Migration
  def change
    create_table :user_zones do |t|
      t.references :user
      t.references :zone
    end

    add_index :user_zones, :user_id
    add_index :user_zones, :zone_id
  end
end
