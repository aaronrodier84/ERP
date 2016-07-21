window.Kisoils ?= {}
selectors = null
values = null

Kisoils.Batch =
  selectors:
    container: -> $(".js-batch-form")
    caseQuantityInput: -> $('input.js-case-quantity')
    itemQuantityInput: -> $('input.js-item-quantity')

  values:
    itemsPerCase: -> selectors.caseQuantityInput().data("items-per-case")

  init: ->
    selectors = @selectors
    values = @values
    if @isRelevantPage()
      @bindUIActions()
      selectors.itemQuantityInput().trigger('change')

  isRelevantPage: ->
    return selectors.container().length > 0

  bindUIActions: ->
    if @isCaseInputPresent()
      selectors.caseQuantityInput().on 'change', => @updateItemQuantity()
      selectors.caseQuantityInput().on 'keyup', => @updateItemQuantity()
      selectors.itemQuantityInput().on 'change', => @updateCaseQuantity()
      selectors.itemQuantityInput().on 'keyup', => @updateCaseQuantity()

  isCaseInputPresent: ->
    selectors.caseQuantityInput().length > 0

  updateItemQuantity: ->
    itemQty = selectors.caseQuantityInput().val() * values.itemsPerCase()
    itemQtyRounded = Math.round(itemQty)
    selectors.itemQuantityInput().val(itemQtyRounded)

  updateCaseQuantity: ->
    itemQty = selectors.itemQuantityInput().val() / values.itemsPerCase()
    itemQtyRounded = Math.round(itemQty * 100) / 100
    selectors.caseQuantityInput().val(itemQtyRounded)

