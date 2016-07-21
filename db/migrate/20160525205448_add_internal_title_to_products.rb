class AddInternalTitleToProducts < ActiveRecord::Migration
  def change
    add_column :products, :internal_title, :string
  end
end
