window.Kisoils ?= {}
selectors = null

Kisoils.Ingredients =
  selectors:
    container: -> $('.js-edit-product-ingredients')
    removeIcon: -> $('.js-remove')
    addButton: -> $('.js-add-ingredient')
    saveButton: -> $('.js-save')
    materialSelect: -> $('.js-material')
    
    ingredientTrTemplate: -> $('.js-ingredient-template')
    allIngredientTrs: -> $('tr.js-ingredient').not('.js-ingredient-template')
    trOf: (innerElement) -> $(innerElement).parents('tr')

    productId: -> selectors.container().data('product-id')
    trMaterialId:   (tr) -> $(tr).find('.js-material').val()
    trMaterialName: (tr) -> $(tr).find('.js-material').find("option:selected").text()
    trQuantity:     (tr) -> $.trim( $(tr).find('.js-quantity').val() )

  init: ->
    selectors = @selectors
    if @isRelevantPage()
      @bindUIActions()

  isRelevantPage: ->
    return selectors.container().length > 0

  bindUIActions: ->
    selectors.container().on 'change', '.js-material', (event) => @showMaterialInfo(event.target)
    selectors.container().on 'click', '.js-remove', (event) => @removeIngredient(event.target)
    selectors.addButton().on 'click', => @addIngredient()
    selectors.saveButton().on 'click', => @saveIngredients()

  showMaterialInfo: (materialSelect) ->
    materialSelect = $(materialSelect)
    selectedMaterialUnit = materialSelect.find("option:selected").data('unit')
    selectedMaterialUnit = '' if (selectedMaterialUnit == undefined)
    materialTr = selectors.trOf(materialSelect)
    unitLabel = materialTr.find('.js-unit')
    unitLabel.text(selectedMaterialUnit)

  addIngredient: -> 
    template = selectors.ingredientTrTemplate()
    newTr = template.clone()
    newTr.removeClass('js-ingredient-template')
    template.before(newTr)

  removeIngredient: (removeIcon) -> 
    removeIcon = $(removeIcon)
    materialTr = selectors.trOf(removeIcon)
    materialTr.remove()

  saveIngredients: ->
    productId = selectors.productId()

    ingredients = []
    for tr in selectors.allIngredientTrs()
      materialId = selectors.trMaterialId(tr)
      continue if ( materialId == '0')
      quantity = selectors.trQuantity(tr)
      if (quantity == '')
        alert "Please select quantity for " + selectors.trMaterialName(tr)
        return
      ingredients.push({material_id: materialId, quantity: quantity})

    $.ajax '/products/' + productId + '/ingredients',
      method: 'post'
      data: { ingredients: ingredients }
      dataType: 'json'
      timeout: 8000
      success: (json) ->
        window.location.href = json["redirect_to"]
      error: (result) ->
        error_message = result.responseJSON["error_message"]
        if error_message && (error_message.length > 0)
          alert "ERROR! " + error_message
        else
          alert "Sorry, but something went wrong. Please check your input and try again."
