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

class Vendor < ActiveRecord::Base
  has_many :invoices
  validates_presence_of :name
  validates :website, :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
end
