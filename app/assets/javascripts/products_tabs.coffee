window.Kisoils ?= {}
selectors = null

Kisoils.ProductsTabs =
  selectors:
    productsZoneTabs : -> $('.js-products-zone-tab')
    activeTab: -> $('.nav.nav-tabs li.active a')
    specificZoneTab: (zone) -> $(".js-products-zone-tab[data-zone=#{zone}]")
    productsZoneTabContent: (zone) ->$(".js-tab-products-#{zone}")

  init: ->
    selectors = @selectors
    @bindUIActions()
    @setTabFromHash()
    @loadDefaultTab()

  bindUIActions: ->
    selectors.productsZoneTabs().on 'show.bs.tab', (event) => @updateHash(event.target.hash)
    selectors.productsZoneTabs().on 'click', (event) => @loadProductsForZone(event.currentTarget)

  setTabFromHash: ->
    hash = document.location.hash
    if hash
      zoneName = hash.substring(1)
      selectors.specificZoneTab(zoneName).tab('show')

  updateHash: (newHash) ->
    window.location.hash = newHash
    window.scrollTo(0,0)

  # element is the tab
  loadProductsForZone: (element) ->
    element = $(element)
    url = element.data('productsUrl')
    zone = element.data('zone')
    $.get(url, (data) -> selectors.productsZoneTabContent(zone).html(data))
    element.tab('show')
    return false

  loadDefaultTab: ->
    tab = selectors.activeTab()
    @loadProductsForZone(tab)


