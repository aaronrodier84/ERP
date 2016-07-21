def populate_zones
  create(:zone, name: "Make", production_order: 1)
  create(:zone, name: "Pack", production_order: 2)
  create(:zone, name: "Ship", production_order: 3)
end
