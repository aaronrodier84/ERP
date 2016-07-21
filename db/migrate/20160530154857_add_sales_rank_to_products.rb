class AddSalesRankToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sales_rank, :integer
  end
end
