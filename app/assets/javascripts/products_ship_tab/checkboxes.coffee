window.Kisoils ?= {}
selectors = null

Kisoils.ProductsShipTabCheckboxes =
  selectors:
    selectAllProductsCheckbox: -> $('.js-select-all')
    allVisibleProductCheckboxes: -> $('tbody input[type="checkbox"]:visible')

  init: ->
    selectors = @selectors
    @bindUIActions()

  bindUIActions: ->
    selectors.selectAllProductsCheckbox().on 'change',
      (event) => @processSelectAllCheckbox(event)

  # --- --- --- "Select All" checkboxes --- --- ---
  processSelectAllCheckbox: (event) ->
    selectAllCheckbox = $(event.target)
    checked = selectAllCheckbox.prop("checked")
    @toggleVisibleProductsSelection(checked)

  toggleVisibleProductsSelection: (checked) ->
    selectors.selectAllProductsCheckbox().prop("checked", checked)
    selectors.allVisibleProductCheckboxes().prop("checked", checked)

  unselectAllProducts: ->
    @toggleVisibleProductsSelection(false)

