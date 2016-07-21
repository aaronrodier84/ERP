# In-pace field editing.
# Use in_place_editable helper for markup

window.Kisoils ?= {}
selectors = null

Kisoils.InPlaceEditor =
  selectors:
    container: -> $('.js-in-place-editable')
    contaiterFor: (inner_element) -> inner_element.parents('.js-in-place-editable')
    formFor: (link_or_input) -> @contaiterFor(link_or_input).find('form')
    linkFor: (form_or_input) -> @contaiterFor(form_or_input).find('a')

  init: ->
    selectors = @selectors
    @bindUIActions()

  bindUIActions: ->
    $('body').on 'click', '.js-in-place-editable a', @showForm
    $('body').on 'keypress', '.js-in-place-editable form input', @submitFormIfEnter
    $('body').on 'blur', '.js-in-place-editable form', @submitForm

  showForm: (event) ->
    theLink = $(this)
    selectors.formFor(theLink).show()
    theLink.hide()
    event.preventDefault()

  submitFormIfEnter: (event) ->
    if event.keyCode == 13  # Enter pressed
      Kisoils.InPlaceEditor.submitForm(event)

  submitForm: (event) ->
    event.preventDefault()
    theInput = $(event.target)
    theLink = selectors.linkFor(theInput)
    theForm = selectors.formFor(theInput)
    
    form_data = theForm.serialize()
    form_url  = theForm.attr('action')
    $.ajax form_url,
      data: form_data
      dataType: 'json'
      type: 'put'
      # ideally this would be 'patch' type but impossible to auto-test:
      # https://github.com/thoughtbot/capybara-webkit/issues/553
      success: (json)->
        theForm.hide()
        link_text = theInput.val()
        link_text = 'N/A' unless link_text
        theLink.text(link_text)
        theLink.show()
        if Kisoils.InPlaceEditor.isPageReloadRequired(theLink)
          location.reload()
        else
          # Trigger further custom processing of the successful update.
          theLink.trigger('successfulUpdate', [json])
      error: (response)->
        alert "Error! " + response.responseJSON.error

  isPageReloadRequired: (inner_element) ->
    selectors.contaiterFor(inner_element).data('reload')
