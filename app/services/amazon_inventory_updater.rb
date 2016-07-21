# frozen_string_literal: true
class AmazonInventoryUpdater
  include Logging

  # http://www.amazon.com/gp/help/customer/display.html/?nodeId=200680710
  # http://docs.developer.amazonservices.com/en_US/reports/Reports_ReportType.html#ReportTypeCategories__FBAReports

  # Beacuse reports take a variable amount of time to be generated,
  # we request a report, then just get the latest one. If we run this each hour we should be fine.

  REPORTS_RANGE = 4.days

  def self.build
    inventory_api = Amazon::InventoryApi.build(Setting.instance.amazon_config)
    update_inventory_action = AmazonInventories::UpdateAmazonInventory.new
    new(inventory_api, update_inventory_action)
  end

  def initialize(inventory_api, update_inventory_action)
    @inventory_api = inventory_api
    @update_inventory_action = update_inventory_action
  end

  def run
    log "Started updating Amazon inventory"
    report = fetch_latest_report
    log "Latest report: #{report.inspect}"
    return unless report.present?

    report_data = inventory_api.fetch_report report['ReportId']

    log "Parsing report inventory data"
    inventory_data = parse_csv_report(report_data)

    log "Saving Amazon inventories"
    results = inventory_data.map { |inventory| update_inventory(inventory) }.compact

    log "Finished updating Amazon inventory"
    results
  end

  private

  attr_reader :inventory_api, :update_inventory_action

  def fetch_latest_report
    reports = inventory_api.fetch_reports REPORTS_RANGE
    sorted_reports = reports.sort_by { |report| report.dig('AvailableDate')&.to_datetime }
    sorted_reports.first
  end

  def parse_csv_report(report)
    fixed_report = report.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    CSV.parse(fixed_report, headers: true, col_sep: "\t").map do |line|
      to_inventory_info line
    end
  end

  def to_inventory_info(inventory_data)
    inventory = inventory_data.to_h
    quantities = %w(fulfillable reserved inbound_working inbound_shipped).map do |type|
      column_name = "afn-#{type}-quantity".tr('_', '-')
      [type, inventory[column_name]]
    end
    OpenStruct.new fnsku: inventory['fnsku'], params: Hash[quantities]
  end

  def update_inventory(inventory)
    product = Product.find_by fnsku: inventory.fnsku
    return unless product
    amazon_inventory = product.amazon_inventory

    update_inventory_action.call amazon_inventory, inventory.params
  end
end
