# == Schema Information
#
# Table name: vendors
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  contact_name  :string
#  phone         :string
#  contact_email :string
#  contact_fax   :string
#  order_email   :string
#  order_fax     :string
#  tags          :string
#  address       :string
#  notes         :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  website       :string
#

FactoryGirl.define do
  factory :vendor do
    name 'John Mack'
    website 'http://example.com'
  end
end
