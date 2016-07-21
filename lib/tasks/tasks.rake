# frozen_string_literal: true
namespace :scheduled do
  desc 'Fetches product from Amazon'
  task :get_products => :environment do
    FetchProductsJob.perform_later
  end

  desc 'Updated amazon inventory status for each product'
  task :get_inventory => :environment do
    UpdateAmazonInventoryJob.perform_later
  end

  desc 'Requests report for inventory at Amazon'
  task :request_amazon_report => :environment do
    RequestAmazonReportJob.perform_later
  end
end

namespace :tasks do
  task :update_floats => :environment do
    Product.update_all 'weeks_of_cover = 0.0'
    Product.update_all 'sold_last_24_hours = 0.0'
    Product.update_all 'inbound_qty = 0.0'
    Product.update_all 'sellable_qty = 0.0'
  end

  task :create_admin => :environment do
    User.find_by_email('mehatem@gmail.com').update_attribute(:admin, true)
    User.find_by_email('mac.martine+1@gmail.com').update_attribute(:admin, true)
  end

  task :setup => :environment do
    Zone.find_by_name('Filling').update_attribute :name, 'Make'
    Zone.find_by_name('Packaging').update_attribute :name, 'Pack'
    Zone.create(name: 'Ship')
  end
end
