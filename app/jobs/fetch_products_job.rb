class FetchProductsJob < ActiveJob::Base
  queue_as :default

  def perform
		date = 4.years.ago.to_date.to_s(:iso8601)
    AmazonProductsFetcher.build.run date
  end
end
