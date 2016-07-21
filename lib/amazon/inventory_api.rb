module Amazon
  class InventoryApi
    include Logging

    AMAZON_REPORT_NAME = '_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_' 
    INVENTORY_DATA_KEY = '_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_'

    def self.build(config = {})
      reports_client = MWS.reports(config)
      new(reports_client)
    end

    def initialize(reports_client)
      @reports_client = reports_client
    end

    # only asks Amazon to prepair report, it can take up to few hours
    # to make the report on Amazon side. Fetch reports with #fetch_reports
    def request_report
      reports_client.request_report(AMAZON_REPORT_NAME)
    end

    def fetch_reports(reports_range)
      start_date = reports_range.ago.to_date.to_s(:iso8601)
      reports_lists  = fetch_reports_lists(start_date) 
      reports_lists.compact.flat_map { |list| extract_reports(list) }
    end

    def fetch_report(report_id)
      log "Fetching report data for #{report_id}"
      report = reports_client.get_report(report_id)
      return nil unless report
      report.body
    end

    private
    attr_reader :reports_client

    def fetch_reports_lists(start_date)
      log "Getting initial reports list from Amazon"
      reports_list = fetch_initial_reports_list(start_date)
      return [] unless reports_list

      reports_lists = [reports_list]
      while reports_list['NextToken']
        log "Getting following reports list from Amazon"
        reports_list = fetch_next_reports_list reports_list['NextToken']
        reports_lists << reports_list
      end
      reports_lists
    end

    def extract_reports(list)
      report_info = list['ReportInfo']
      return [] unless report_info
      report_info.select { |r| r['ReportType'] == INVENTORY_DATA_KEY }
    end

	  def fetch_initial_reports_list(start_date)
      reports_list = reports_client.get_report_list({available_from_date: start_date})
      reports_list.parse
	  rescue => e
	    log "Error while fetching initial reports list: #{e.message}", :error
	    nil
	  end

	  def fetch_next_reports_list(token)
			reports_list = reports_client.get_report_list_by_next_token(token)
			reports_list.parse
	  rescue => e
	    log "Error while fetching following reports list:: #{e.message}", :error
	    nil
	  end
  end
end
