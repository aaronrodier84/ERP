module FormattedDate
  # For date/time formats to be used across the app, see date_time_formats.rb

  # "05/26/2016" to date
  def friendly_string_to_date(string)
    return nil unless string.present?
    Date.strptime(string, Date::DATE_FORMATS[:short])
  end
end
