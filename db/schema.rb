# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160713155849) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "amazon_inventories", force: :cascade do |t|
    t.integer "fulfillable",     default: 0
    t.integer "reserved",        default: 0
    t.integer "inbound_working", default: 0
    t.integer "inbound_shipped", default: 0
    t.integer "product_id"
  end

  add_index "amazon_inventories", ["product_id"], name: "index_amazon_inventories_on_product_id", using: :btree

  create_table "amazon_inventory_histories", force: :cascade do |t|
    t.integer  "fulfillable"
    t.integer  "reserved"
    t.integer  "inbound_working"
    t.integer  "inbound_shipped"
    t.datetime "reported_at"
    t.integer  "amazon_inventory_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "amazon_inventory_histories", ["amazon_inventory_id"], name: "index_amazon_inventory_histories_on_amazon_inventory_id", using: :btree
  add_index "amazon_inventory_histories", ["reported_at"], name: "index_amazon_inventory_histories_on_reported_at", using: :btree

  create_table "batches", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "quantity"
    t.text     "notes"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.date     "completed_on"
    t.integer  "zone_id"
  end

  create_table "batches_users", force: :cascade do |t|
    t.integer "batch_id"
    t.integer "user_id"
  end

  create_table "fba_allocations", force: :cascade do |t|
    t.integer "fba_warehouse_id", null: false
    t.integer "product_id",       null: false
    t.integer "quantity",         null: false
  end

  add_index "fba_allocations", ["fba_warehouse_id"], name: "index_fba_allocations_on_fba_warehouse_id", using: :btree
  add_index "fba_allocations", ["product_id", "fba_warehouse_id"], name: "index_fba_allocations_on_product_id_and_fba_warehouse_id", unique: true, using: :btree

  create_table "fba_warehouses", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fba_warehouses", ["name"], name: "index_fba_warehouses_on_name", using: :btree

  create_table "ingredients", force: :cascade do |t|
    t.integer  "material_id",             null: false
    t.integer  "product_id",              null: false
    t.integer  "quantity",    default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ingredients", ["material_id"], name: "index_ingredients_on_material_id", using: :btree
  add_index "ingredients", ["product_id", "material_id"], name: "index_ingredients_on_product_id_and_material_id", unique: true, using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "invoice_number"
    t.float    "total"
    t.datetime "due_date"
    t.integer  "vendor_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "materials", force: :cascade do |t|
    t.integer  "zone_id",                          null: false
    t.string   "name",                             null: false
    t.string   "unit"
    t.decimal  "unit_price",         default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_quantity", default: 0,   null: false
  end

  add_index "materials", ["zone_id"], name: "index_materials_on_zone_id", using: :btree

  create_table "product_inventories", force: :cascade do |t|
    t.integer "quantity",   default: 0
    t.integer "product_id"
    t.integer "zone_id"
  end

  create_table "product_zone_availabilities", force: :cascade do |t|
    t.integer "product_id"
    t.integer "zone_id"
  end

  add_index "product_zone_availabilities", ["product_id"], name: "index_product_zone_availabilities_on_product_id", using: :btree
  add_index "product_zone_availabilities", ["zone_id"], name: "index_product_zone_availabilities_on_zone_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "title"
    t.string   "seller_sku"
    t.text     "asin"
    t.string   "fnsku"
    t.string   "size"
    t.string   "list_price_amount"
    t.string   "list_price_currency"
    t.integer  "total_supply_quantity"
    t.integer  "in_stock_supply_quantity"
    t.string   "small_image_url"
    t.boolean  "is_active",                default: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.float    "inbound_qty",              default: 0.0
    t.float    "sold_last_24_hours",       default: 0.0
    t.float    "weeks_of_cover",           default: 0.0
    t.float    "sellable_qty",             default: 0.0
    t.string   "internal_title"
    t.integer  "sales_rank"
    t.float    "selling_price_amount"
    t.string   "selling_price_currency"
    t.integer  "items_per_case",           default: 0,    null: false
    t.integer  "production_buffer_days",   default: 35,   null: false
    t.integer  "batch_min_quantity",       default: 0,    null: false
    t.integer  "batch_max_quantity"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "aws_access_key_id"
    t.string   "aws_secret_key"
    t.string   "mws_marketplace_id"
    t.string   "mws_merchant_id"
    t.string   "address_name"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip_code"
    t.string   "address_country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_zones", force: :cascade do |t|
    t.integer "user_id"
    t.integer "zone_id"
  end

  add_index "user_zones", ["user_id"], name: "index_user_zones_on_user_id", using: :btree
  add_index "user_zones", ["zone_id"], name: "index_user_zones_on_zone_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_active",              default: true
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "contact_name"
    t.string   "phone"
    t.string   "contact_email"
    t.string   "contact_fax"
    t.string   "order_email"
    t.string   "order_fax"
    t.string   "tags"
    t.string   "address"
    t.text     "notes"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "website"
  end

  create_table "zones", force: :cascade do |t|
    t.string  "name"
    t.integer "production_order"
  end

  add_foreign_key "ingredients", "materials"
  add_foreign_key "ingredients", "products"
  add_foreign_key "materials", "zones"
end
