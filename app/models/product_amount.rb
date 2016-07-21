# frozen_string_literal: true
class ProductAmount
  attr_reader :quantity

  def initialize(quantity)
    @quantity = quantity
  end

  # per_day = "reserved"
  def days(per_day)
    per_day = 1 if per_day.zero?
    (quantity.to_f / per_day).round(1)
  end

  def cases(per_case)
    return 0 unless quantity
    return 0 if per_case.zero?
    quantity / per_case
  end

  def case_excess(per_case)
    per_case = 1 if per_case.zero?
    quantity % per_case
  end

  def case_excess_percent(per_case)
    return 0 if per_case.zero?
    100 * case_excess(per_case) / per_case
  end

  def cost(unit_price)
    return 0 unless unit_price
    quantity * unit_price
  end
end
