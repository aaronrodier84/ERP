# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require jquery.turbolinks
#= require bootstrap/dist/js/bootstrap
#= require startbootstrap-sb-admin-2/dist/js/sb-admin-2
#= require bootstrap-datepicker
#= require metisMenu/dist/metisMenu.min

#= require highcharts
#= require highcharts/highcharts-more

#= require in_place_editor
#= require messagebox
#= require product
#= require products_tabs
#= require products_ship_tab/checkboxes
#= require products_ship_tab/products_ship_tab
#= require product_case_switcher
#= require batch
#= require batches
#= require ingredients

$ ->
  initPlugins()
  Kisoils.InPlaceEditor.init()
  Kisoils.Messagebox.init()
  Kisoils.ProductCaseSwitcher.init()
  Kisoils.Batch.init()
  Kisoils.Batches.init()
  Kisoils.Product.init()
  Kisoils.ProductsTabs.init()
  Kisoils.ProductsShipTab.initWithDelay()
  Kisoils.Ingredients.init()

initPlugins = ->
  $('.datepicker').datepicker()
  $('[data-toggle="tooltip"]').tooltip()

  $('body').on 'click', '.not-implemented', (e) ->
    alert "This action is not implemented yet."
    e.preventDefault()
  
