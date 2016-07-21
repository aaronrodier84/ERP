module WithThrottling

  SUPPORTED_INTERVALS = [:second, :minute, :hour, :day, :week, :month, :year]

  def throttle(amount, per:)
    time_to_sleep = time_to_seconds(per) / amount.to_f
    result = yield
    sleep time_to_sleep
    result
  end

  private

  def time_to_seconds(interval)
    return 0 unless SUPPORTED_INTERVALS.include?(interval)
    1.send(interval.to_s).seconds
  end
end
