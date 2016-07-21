module Logging
  def log(message, level = :info)
    message = "[#{self.class.name}] -- #{message}"
    Rails.logger.send(level.to_s, message)
  end
end
