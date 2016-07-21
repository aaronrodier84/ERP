class AddSellingPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :selling_price_amount, :float
    add_column :products, :selling_price_currency, :string
  end
end
