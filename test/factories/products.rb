# == Schema Information
#
# Table name: products
#
#  id                       :integer          not null, primary key
#  title                    :string
#  seller_sku               :string
#  asin                     :text
#  fnsku                    :string
#  size                     :string
#  list_price_amount        :string
#  list_price_currency      :string
#  total_supply_quantity    :integer
#  in_stock_supply_quantity :integer
#  small_image_url          :string
#  is_active                :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  inbound_qty              :float            default(0.0)
#  sold_last_24_hours       :float            default(0.0)
#  weeks_of_cover           :float            default(0.0)
#  sellable_qty             :float            default(0.0)
#  internal_title           :string
#  sales_rank               :integer
#  selling_price_amount     :float
#  selling_price_currency   :string
#

FactoryGirl.define do
  factory :product do
    production_buffer_days 35

    trait :active do
      is_active  true
    end

    trait :inactive do
      is_active  false
    end
  end
end
