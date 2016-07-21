window.Kisoils ?= {}
selectors = null

Kisoils.Product =
  selectors:
    productCheckboxes: -> $('.js-product-active, .js-product-zones input')
    internalTitleInput: -> $('input#internal-title')
    idInput: -> $('input#id')

  init: ->
    selectors = @selectors
    @bindUIActions()

  bindUIActions: ->
    selectors.productCheckboxes().on 'click', -> $(this.form).submit()
    selectors.internalTitleInput().bind('change', (e) => @saveInternalTitle())

  saveInternalTitle: ->
    $.ajax({
      type: "PUT",
      url: '/products/' + selectors.idInput().val() + '/save_internal_title',
      data: {internal_title: selectors.internalTitleInput().val()},
      success: (data) ->
        console.log(data)
      ,
      dataType: "json"
    });

