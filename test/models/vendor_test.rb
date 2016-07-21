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

require 'test_helper'

class VendorTest < ActiveSupport::TestCase

end
