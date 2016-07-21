# frozen_string_literal: true
require 'test_helper'
class RequestAmazonReportJobTest < ActiveJob::TestCase
  it 'requests repors through amazon api' do
    api = mock(:request_report)
    job = RequestAmazonReportJob.new
    job.stubs(:inventory_api).returns(api)
    job.perform_now
  end
end
