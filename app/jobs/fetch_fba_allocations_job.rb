class FetchFbaAllocationsJob < ActiveJob::Base
  include MwsStructs
  queue_as :default

  def perform
    AmazonFbaAllocationsFetcher.build(ship_from_address).run
  end
end
