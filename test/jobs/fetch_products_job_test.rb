require 'test_helper'

class FetchProductsJobTest < ActiveJob::TestCase

  it 'calls products fetcher to get results' do
    fetcher = stub
    fetcher.expects(:run).once
    AmazonProductsFetcher.stubs(:build).returns(fetcher)

    FetchProductsJob.perform_now
  end

  it 'asks fetcher to fetch products for last 4 years' do
    current_date = Date.new(2014,10,1)
    Timecop.travel(current_date)
    
    fetcher = stub
    fetcher.expects(:run).with("2010-10-01")
    AmazonProductsFetcher.stubs(:build).returns(fetcher)
    FetchProductsJob.perform_now
  end

  after do
    Timecop.return
  end
end
