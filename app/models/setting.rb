# This is model holding global application settings.
# When there are too many setting, migrate to an alternative solution:
# https://github.com/huacnlee/rails-settings-cached

# == Schema Information
#
# Table name: settings
#
#  id                 :integer          not null, primary key
#  aws_access_key_id  :string
#  aws_secret_key     :string
#  mws_marketplace_id :string
#  mws_merchant_id    :string
#  address_name       :string
#  address_line1      :string
#  address_line2      :string
#  address_city       :string
#  address_state      :string
#  address_zip_code   :string
#  address_country    :string
#  created_at         :datetime
#  updated_at         :datetime
#

class Setting < ActiveRecord::Base

  def self.instance
    Setting.first || Setting.new
  end

  def amazon_config
    { aws_access_key_id: aws_access_key_id, aws_secret_access_key: aws_secret_key, merchant_id: mws_merchant_id, primary_marketplace_id: mws_marketplace_id}
  end
end
