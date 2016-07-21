class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.string :name
    end
  end
end
