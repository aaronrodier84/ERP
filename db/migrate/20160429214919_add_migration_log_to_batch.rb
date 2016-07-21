class AddMigrationLogToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :user_id, :integer
    #add_column :batches, :product_id, :integer
    #add_column :batches, :quantity, :integer
    add_column :batches, :completed_on, :datetime
    add_column :batches, :status, :integer
    #add_column :batches, :notes, :text
  end
end
