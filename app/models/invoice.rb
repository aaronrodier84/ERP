# == Schema Information
#
# Table name: invoices
#
#  id             :integer          not null, primary key
#  invoice_number :integer
#  total          :float
#  due_date       :datetime
#  vendor_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Invoice < ActiveRecord::Base
  belongs_to :vendor
end
