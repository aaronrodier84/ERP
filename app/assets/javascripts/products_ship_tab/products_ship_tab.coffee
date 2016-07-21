window.Kisoils ?= {}
selectors = null

Kisoils.ProductsShipTab =
  selectors:
    container: -> $(".js-tab-products-ship")

    shipButtonPanel: -> $('.js-ship-panel')
    warehouseSelect: -> $(".js-filter .js-warehouse")
    selectedWarehouseId: -> selectors.warehouseSelect().val()
    selectedWarehouseName: -> selectors.warehouseSelect().find("option:selected").text()
    shipButton: -> @shipButtonPanel().find('.js-ship-button')
    shipmentNameInput: -> @shipButtonPanel().find('.js-shipment-name')
    shipmentName: -> @shipmentNameInput().val()
    
    closestTr: (element) -> $(element).closest('tr')
    productId: (trOrInnerElement) -> @closestTr(trOrInnerElement).data('product-id')

    productFbaAllocationTd: (productId) ->
      $('tr[data-product-id="' + productId + '"] td.js-fba-allocation')
    allWarehouseRecords: -> $('td.js-fba-allocation .warehouse')
    warehouseRecords: (warehouseId) ->
      $('td.js-fba-allocation .warehouse[data-warehouse-id="' + warehouseId + '"]')
    
    allProductTrs:    -> $('tbody tr')
    warehouseProductTrs: (warehouseId) -> @warehouseRecords(warehouseId).parents('tr')

    allVisibleCheckedProductCheckboxes: -> $('tbody input[type="checkbox"]:checked:visible')
    selectedProductTrs: -> @allVisibleCheckedProductCheckboxes().parents('tr')

    toShipQantityOverrideInputs:  -> $('.js-to-ship-qty-override')
    toShipQantityOverrideLinks:   -> $('.js-in-place-editable .js-to-ship-qty-override-link')

  # This is a bad practice, but this code will be fixed
  # as long as tabs are going to be moved to the menu.
  initWithDelay: ->
    window.setTimeout(@init, 2500)

  init: ->
    selectors = Kisoils.ProductsShipTab.selectors
    if Kisoils.ProductsShipTab.isRelevantPage()
      Kisoils.ProductsShipTab.bindUIActions()
      selectors.shipButtonPanel().hide()  # Ship panel is initially hidden
      Kisoils.ProductsShipTab.populateAllFbaAllocations()
      Kisoils.ProductsShipTabCheckboxes.init()
      
      # Have to re-init these when the tab is loaded.
      # Tabs will be removed soon, this code won't be needed then.
      Kisoils.ProductCaseSwitcher.init()
      Kisoils.Messagebox.init()

  isRelevantPage: ->
    return selectors.container().length > 0

  bindUIActions: ->
    selectors.warehouseSelect().on 'change', (event) => @filterWarehouseProducts(event)
    selectors.shipButton().on 'click', (event) => @shipSelectedProducts(event)

    # Hooking jQuery custom event on successful in-place editing of ship count override field.
    selectors.toShipQantityOverrideLinks().on 'successfulUpdate', (event, fbaAllocations) =>
      @updateFbaAllocation(event.target, fbaAllocations)

  # --- --- --- FBA Warehouse/Allocation processing --- --- ---
  filterWarehouseProducts: () ->
    selectedWarehouseId = selectors.selectedWarehouseId()
    if selectedWarehouseId == 'all'
      selectors.allProductTrs().show()
      selectors.shipButtonPanel().hide()
    else
      # Kisoils.ProductsShipTab.unselectAllProducts()
      selectors.allProductTrs().hide()
      selectors.warehouseProductTrs(selectedWarehouseId).show()
      Kisoils.ProductsShipTab.showShipButtonPanel()
    Kisoils.ProductsShipTab.highlightCurrentWarehouse()

  highlightCurrentWarehouse: ->
    currentWarehouseId = selectors.selectedWarehouseId()
    selectors.allWarehouseRecords().removeClass('highlighted')
    selectors.warehouseRecords(currentWarehouseId).addClass('highlighted')

  # Populates all FBA allocations
  populateAllFbaAllocations: ->
    for tr in selectors.allProductTrs()
      productId = $(tr).data('product-id')
      Kisoils.ProductsShipTab.displayFbaAllocation(productId)

  # Updates FBA Allocation info for a certain product
  # fbaAllocations JSON format:
  # [{warehouse_id: 3, warehouse_name: 'ABC1', quantity: 3240}, {}, ...]
  updateFbaAllocation: (shipCountOverrideLink, fbaAllocations) ->
    # fill out the data attribute and trigger further display action
    productId = selectors.productId(shipCountOverrideLink)
    allocationTd = selectors.productFbaAllocationTd(productId)
    allocationTd.data('fba-allocations', fbaAllocations)
    Kisoils.ProductsShipTab.displayFbaAllocation(productId)


  # Displays product FBA allocation information from td's "data-fba-allocations" attribute.
  displayFbaAllocation: (productId) ->
    allocationTd = selectors.productFbaAllocationTd(productId)
    allocationTd.find('.warehouse').remove()
    fbaAllocations = allocationTd.data('fba-allocations')
    packedInventoryQuantity = parseInt(allocationTd.data('packed-inventory-quantity'))

    for allocation in fbaAllocations
      allocation = $.parseJSON(allocation)
      warehouseDiv = $('<div>', {class: 'warehouse'})
      warehouseDiv.data(     'warehouse-id', allocation['warehouse_id'])
      warehouseDiv.attr('data-warehouse-id', allocation['warehouse_id'])
      warehouseDiv.text(allocation['warehouse_name'] + ':\xa0' + allocation['quantity'])
      if parseInt(allocation['quantity']) > packedInventoryQuantity
        warehouseDiv.addClass('error-overflow')
      allocationTd.append(warehouseDiv)
    Kisoils.ProductsShipTab.highlightCurrentWarehouse()


  # --- --- --- "Ship!" button processing --- --- ---
  showShipButtonPanel: ->
    selectors.shipButton().text("Ship Selected to " + selectors.selectedWarehouseName())
    currentDate = new Date()
    shipmentName = currentDate.getFullYear() + '/' + (currentDate.getMonth()+1).toString() +
      '/' + currentDate.getDate() + ' ' + selectors.selectedWarehouseName()
    selectors.shipmentNameInput().val(shipmentName)
    selectors.shipButtonPanel().show()

  validateQuantityOverride: ->
    isValid = true
    warehouseId = parseInt(selectors.selectedWarehouseId())
    selectors.selectedProductTrs().each( ->
      productId = $(this).data('product-id')
      allocationTd = selectors.productFbaAllocationTd(productId)
      packedInventoryQuantity = parseInt(allocationTd.data('packed-inventory-quantity'))
      fbaAllocations = allocationTd.data('fba-allocations')

      for allocation in fbaAllocations
        allocation = $.parseJSON(allocation)
        if parseInt(allocation.warehouse_id) == warehouseId && parseInt(allocation.quantity) > packedInventoryQuantity
          isValid = false

    )
    return isValid

  shipSelectedProducts: (e) ->
    e.preventDefault()

    if Kisoils.ProductsShipTab.validateQuantityOverride() == false
      Kisoils.Messagebox.show("FBA allocation should be less than packed inventory quantity! (marked as red color)")
      return

    productsToShip = selectors.selectedProductTrs().map(->
      {
      product_id: $(this).data('product-id'),
      quantity: $(this).find('#product_to_ship_item_qty_override').val()
      }
    ).get()

    warehouseId = selectors.selectedWarehouseId()
    shipmentName = selectors.shipmentName()

    if productsToShip.length == 0
      Kisoils.Messagebox.show("No products selected to ship!")
    else
      $.ajax({
        method: 'POST',
        dataType: 'JSON',
        url: '/batches/create_with_shipment',
        data: {productsToShip: JSON.stringify(productsToShip), shipmentName: shipmentName, warehouseId: warehouseId},
        beforeSend: ->
          Kisoils.Messagebox.show("Shipping is in progress. Please wait for a while!")
        success: ->
          Kisoils.Messagebox.show("Shipping is done successfully!")
          location.href = "/batches"
        error: (data) ->
          if data.responseJSON.error.code == 'err_overflow_inventory'
            Kisoils.Messagebox.show("Shipping fails. Overflow inventory quantity. Reloading!")
            location.reload()
            return
          Kisoils.Messagebox.show("Shipping fails. Check and try again!")
      })
