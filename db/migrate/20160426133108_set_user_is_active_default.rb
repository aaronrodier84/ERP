class SetUserIsActiveDefault < ActiveRecord::Migration
  def change
    change_column :users, :is_active, :boolean, :default => true
  end
end
