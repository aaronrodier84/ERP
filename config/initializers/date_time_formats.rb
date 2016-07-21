# These are date/time formats that are used across the app:
# a_date.to_s          # => "May 26, 2016" (a default for all implicit conversions)
# a_date.to_s(:long)   # => "Thursday May 26, 2016"
# a_date.to_s(:short)  # => "05/26/2016"
# a_date&.to_s(:long)  # if the date can be nil
# a_time.to_s          # => "May 26, 2016 12:00 PM" (a default for all implicit conversions)
# a_time.to_s(:long)   # => "Thursday May 26, 2016 12:00 PM"
# a_time.to_s(:short)  # => "05/26/2016 12:00 PM"
Date::DATE_FORMATS[:default] = '%b %d, %Y'
Date::DATE_FORMATS[:long]    = '%A %b %d, %Y'
Date::DATE_FORMATS[:short]   = '%m/%d/%Y'
Time::DATE_FORMATS[:default] = '%b %d, %Y %I:%M %p'
Time::DATE_FORMATS[:long]    = '%A %b %d, %Y %I:%M %p'
Time::DATE_FORMATS[:short]   = '%m/%d/%Y %I:%M %p'
