# == Schema Information
#
# Table name: zones
#
#  id                     :integer          not null, primary key
#  name                   :string
#  production_order       :integer
#  production_buffer_days :integer          default(30), not null
#

FactoryGirl.define do 
  factory :zone do
    name 'Make'

    trait :make do
      name 'Make'
      production_order 1
    end

    trait :pack do
      name 'Pack'
      production_order 2
    end

    trait :ship do
      name 'Ship'
      production_order 3
    end

    trait :visible do
      name 'Make'
    end

    trait :invisible do
      name 'not Make not Pack'
    end
  end
end
