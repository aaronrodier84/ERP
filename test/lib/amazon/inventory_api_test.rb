require 'test_helper'

class InventoryApiTest < ActiveSupport::TestCase

  def described_class
    Amazon::InventoryApi
  end

  describe '.build' do
    it 'builds an instance of inventory api with default dependencies'  do
      inventory_api = described_class.build
      assert_kind_of Amazon::InventoryApi, inventory_api
    end
  end

  describe '#request_report' do
    it 'asks amazon to create new report through client' do
      mws_client = stub
      mws_client.expects(:request_report).with('_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_')
      inventory_api = described_class.new mws_client
      inventory_api.request_report
    end
  end

  describe '#fetch_reports' do
    let(:single_response) { {'NextToken' => nil}}
    let(:response_with_following) { { 'NextToken' => '12345'}}
    let(:result_with_parser) { stub(parse: single_response)}

    after { Timecop.return }

    it 'transforms reports range to correct format for mws client' do
      mws_client = stub
      mws_client.expects(:get_report_list).with({available_from_date: "2010-03-05"}).returns(result_with_parser)

      Timecop.travel(2010, 3, 10)
      api = described_class.new mws_client
      api.fetch_reports 5.days
    end

    it 'fetches report lists from amazon' do
      initial_response = stub(parse: response_with_following)
      next_response = stub(parse: single_response )

      # expect both methods call
      mws_client = mock(get_report_list: initial_response, 
                        get_report_list_by_next_token: next_response)

      api = described_class.new mws_client
      api.fetch_reports 5.days
    end

    it 'extracts inventory data from all report lists' do
      other_key = 'SOME_OTHER_REPORT_INFO_KEY'
      first_list, second_list = 6.times.map do |i|
        report_type = i.odd? ? described_class::INVENTORY_DATA_KEY : other_key  
        { 'ReportType' => report_type, 'Reserved' => 100*i }
      end.split(2)

      initial_response = stub(parse: { 'NextToken' => '123','ReportInfo' => first_list})
      next_response = stub(parse: { 'NextToken' => nil, 'ReportInfo' => second_list})
      mws_client = stub(get_report_list: initial_response, 
                        get_report_list_by_next_token: next_response)
      api = described_class.new mws_client
      results = api.fetch_reports 5.days
      expected = [100,300,500].map { |num| { 'ReportType' => described_class::INVENTORY_DATA_KEY, 'Reserved' => num}}
      assert_equal expected, results
    end
  end

  describe '#fetch_report' do
    let(:report_id) { 12345 }

    it 'fetches report by id through mws client' do
      mws_client = stub
      mws_client.expects(:get_report).with(12345)
      api = described_class.new mws_client
      api.fetch_report(report_id)
    end

    it 'returns response body' do
      expected_result = Object.new 
      response = stub(body: expected_result )
      mws_client = stub(get_report: response )
      api = described_class.new mws_client
      result = api.fetch_report(report_id)
      assert_equal expected_result, result
    end
  end
end
