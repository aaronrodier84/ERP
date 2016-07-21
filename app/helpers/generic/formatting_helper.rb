# frozen_string_literal: true
module Generic
  module FormattingHelper
    # attrs example: {unit: '$'}
    def with_currency(price, attrs = {})
      unit = attrs[:unit] || '$'
      if price == price.round(2)
        number_to_currency(price, unit: unit)
      else
        "#{unit}#{price}"
      end
    end
  end
end
