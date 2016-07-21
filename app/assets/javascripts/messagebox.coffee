window.Kisoils ?= {}
selectors = null

Kisoils.Messagebox =
  selectors:
    messagebox: -> $(".shipment-status-messagebox")
    messageboxCloseButton: -> $(".shipment-status-messagebox .close")

  init: ->
    selectors = @selectors
    @bindUIActions()

  bindUIActions: ->
    selectors.messageboxCloseButton().on 'click', (event) => @hide(event)

  show: (message) ->
    selectors.messagebox().show().find("span").text(message)

  hide: ->
    selectors.messagebox().hide()

