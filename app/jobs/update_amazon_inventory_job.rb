class UpdateAmazonInventoryJob < ActiveJob::Base
  queue_as :default

  def perform
    AmazonInventoryUpdater.build.run
  end
end
