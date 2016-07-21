class Result

  def success?
    false
  end

  def failure?
    !success?
  end

  def entity
    nil
  end

  def errors
    []
  end

  def results
    [self]
  end

  def error_message
    errors.join ' '
  end
end
