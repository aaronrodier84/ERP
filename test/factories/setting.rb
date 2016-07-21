
FactoryGirl.define do 
  factory :setting do
    trait :filled_out do
      address_name       "John Smith"
      address_line1      "1600 Amphitheatre Pkwy"
      address_line2      "-"
      address_city       "Mountain View"
      address_state      "CA"
      address_zip_code   "94043"
      address_country    "USA"

      aws_access_key_id  "AWSACCESSKEY"
      aws_secret_key     "SECRET"
      mws_marketplace_id "MWSMARKETPLACEID"
      mws_merchant_id    "MWSMERCHANTID"
    end
  end
end
