unless Setting.any?
  Setting.create!(
    aws_access_key_id:  "AKIAIO5LDEK7A4ST4NBQ",
    aws_secret_key:     "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",
    mws_marketplace_id: "ATVPDKIKX0DER",
    mws_merchant_id:    "A3801N6NZH2X3P"
  )
end

unless Zone.any?
  %w(Make Pack Ship).each_with_index { |name, index| Zone.create(name: name, production_order: index)}
end

# These are dummy data for demoing.
unless FbaWarehouse.any?
  warehouses = 
  [ {name: "NPA"}, 
    {name: "NPR"}, 
    {name: "HYZ"}, 
    {name: "AAA"}, 
    {name: "BBB"} ]

  warehouses.each do |hash|
    FbaWarehouse.create!(hash)
  end
end

# These are dummy data for demoing.
unless Material.any?
  make_materials = 
  [ 
    { name: "Lemon oil",        unit: "ml", unit_price: "0.09" }, 
    { name: "Bergamot oil",     unit: "ml", unit_price: "0.25" }, 
    { name: "Sweet Orange oil", unit: "ml", unit_price: "0.32" }, 
    { name: "Lavender oil",     unit: "ml", unit_price: "0.12" },
    { name: "Bottle 10ml",      unit: nil,  unit_price: "0.07" },
    { name: "Bottle 30ml",      unit: nil,  unit_price: "0.09" },
    { name: "Cap",              unit: nil,  unit_price: "0.02" }
  ]

  make_materials.each do |hash|
    Material.create!(hash.merge({zone_id: Zone.make_zone.id}))
  end

  pack_materials = 
  [ 
    { name: "Bobble bag",       unit: nil, unit_price: "0.005" }, 
    { name: "Business card",    unit: nil, unit_price: "0.009" },
    { name: "Gift box",         unit: nil, unit_price: "2.99" }
  ]

  pack_materials.each do |hash|
    Material.create!(hash.merge({zone_id: Zone.pack_zone.id}))
  end
end
