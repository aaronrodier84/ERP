window.Kisoils ?= {}
selectors = null

Kisoils.ProductCaseSwitcher =
  selectors:
    togglerItems: -> $(".js-items-cases-toggler .js-items")
    togglerCases: -> $(".js-items-cases-toggler .js-cases")
    elementsForItemsModeOnly: -> $('.js-viewmode-items')
    elementsForCasesModeOnly: -> $('.js-viewmode-cases')

  # This is a bad practice, but this code will be fixed
  # as long as tabs are going to be moved to the menu.
  initWithDelay: ->
    window.setTimeout(@init, 2500)

  init: ->
    selectors = Kisoils.ProductCaseSwitcher.selectors
    Kisoils.ProductCaseSwitcher.bindUIActions()

  bindUIActions: ->
    selectors.togglerItems().on 'click', @showItemNumbers
    selectors.togglerCases().on 'click', @showCaseNumbers

  showItemNumbers: ->
    selectors.elementsForCasesModeOnly().addClass('hidden')
    selectors.elementsForItemsModeOnly().removeClass('hidden')

  showCaseNumbers: ->
    selectors.elementsForCasesModeOnly().removeClass('hidden')
    selectors.elementsForItemsModeOnly().addClass('hidden')

