# frozen_string_literal: true
namespace :data do
  namespace :products do
    desc 'Mark all zones to each product as availalbe'
    task expose_to_all_zones: :environment do
      Product.all.each do |product|
        ExposeProducts.new(product).expose_to_all_zones
      end
    end

    desc 'Creates product inventory for each product and zone'
    task create_inventories: :environment do
      inventories = Product.all.map do |product|
        Zone.all.map do |zone|
          ProductInventory.new product: product, zone: zone
        end
      end.flatten
      ProductInventory.import inventories
    end

    desc 'Resets all product inventories'
    task reset_inventories: :environment do
      ProductInventory.update_all quantity: 0
    end

    desc 'Exports products to csv'
    task :export_csv, [:filename] => :environment do |_, args|
      args.with_defaults(filename: 'tmp/products.csv')
      require 'csv'
      products_csv = CSV.generate do |csv|
        csv << Product.column_names
        Product.all.each do |product|
          csv << product.attributes.values_at(*Product.column_names)
        end
        csv
      end
      File.write(args.filename, products_csv)
    end

    desc 'Import products from csv'
    task :import_csv, [:filename] => :environment do |_, args|
      args.with_defaults(filename: 'tmp/products.csv')
      csv_content = File.read args.filename
      csv = CSV.parse csv_content, headers: true
      csv.each do |row|
        Products::CreateProduct.new.call row.to_hash
      end
    end
  end
end
