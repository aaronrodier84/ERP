require 'test_helper'

class UpdateAmazoninventoryJobTest < ActiveJob::TestCase

  it 'run amazon inventory updater' do
    updater = mock(run: true)
    AmazonInventoryUpdater.expects(:build).returns(updater)

    UpdateAmazonInventoryJob.perform_now
  end
end
