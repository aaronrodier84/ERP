require 'test_helper'
include FormattedDate

class FormattedDateTest < ActiveSupport::TestCase
  describe '.friendly_string_to_date' do
    it "converts string to date correctly" do 
      date_initial = Date.today
      string = date_initial.to_s(:short)
      date_converted_back = friendly_string_to_date(string)
      
      assert_equal date_initial, date_converted_back
    end

    it "processes blank parameters" do 
      assert_nil friendly_string_to_date(nil)
      assert_nil friendly_string_to_date('')
    end
  end
end
