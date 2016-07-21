class RenameStatusToZone < ActiveRecord::Migration
  def change
    rename_column :batches, :status, :zone_id
  end
end
