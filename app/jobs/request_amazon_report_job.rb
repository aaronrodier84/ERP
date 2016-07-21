# frozen_string_literal: true
class RequestAmazonReportJob < ActiveJob::Base
  queue_as :default

  def perform
    inventory_api.request_report
  end

  def inventory_api
    @inventory_api ||= begin
      config = Setting.instance.amazon_config
      Amazon::InventoryApi.build config
    end
  end
end
