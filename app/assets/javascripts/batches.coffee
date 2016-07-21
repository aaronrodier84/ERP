window.Kisoils ?= {}
selectors = null

Kisoils.Batches =
  selectors:
    backButton: -> $('.back-btn')

    batchesViewTabs : -> $('.js-batchs-view-tab')
    activeTab: -> $('.nav.nav-tabs li.active a')
    specificViewTab: (view) -> $(".js-batchs-view-tab[data-view=#{view}]")
    batchesViewTabContent: (view) ->$(".js-tab-batches-#{view}")

    chartContiner: -> $('#chart-container')

    dateRangeSelect: -> $('#date-range')

  init: ->
    selectors = @selectors
    @bindUIActions()

    @setTabFromHash()
    @loadDefaultTab()

  bindUIActions: ->
    selectors.backButton().bind('click', -> history.back())

    selectors.batchesViewTabs().on 'show.bs.tab', (event) => @updateHash(event.target.hash)
    selectors.batchesViewTabs().on 'click', (event) => @loadBatches(event.currentTarget)

    selectors.dateRangeSelect().on 'change', (event) => @loadBatches(selectors.activeTab())

  setTabFromHash: ->
    hash = document.location.hash
    if hash
      viewName = hash.substring(1)
      selectors.specificViewTab(viewName).tab('show')

  loadDefaultTab: ->
    tab = selectors.activeTab()
    @loadBatches(tab)

  loadBatches: (element) ->
    if $(element).data('view') == 'graph-view'

      url = '/batches/get_chart_data?date_range=' + selectors.dateRangeSelect().val()
      $.get(url, (data) ->
        color_series = ['#d9534f', '#f0ad4e', '#5bc0de']
        zone_subtitles = []
        $(data.chart_data).each( (index, zone) ->
          total = 0;
          $(zone.data).each( (index, count) ->
            total += count
          );
          zone_subtitles.push('<span style="color: ' + color_series[index] + '; font-size: 14px;">' + zone.name + ': ' + total + '</span>')
        );

        selectors.chartContiner().highcharts({
          colors: color_series,
          stacked: true,
          chart: {
            type: 'column'
          },
          title: {
            text: 'Production (Last ' + selectors.dateRangeSelect().val() + ' Days)'
          },
          subtitle: {
            text: zone_subtitles.join(', ')
          },
          xAxis: {
            categories: data.days,
            labels: {
              formatter: ->
                return this.value.substring(0, 6);
            }
            crosshair: true
          },
          yAxis: {
            min: 0
          },
          tooltip: {
            headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
            pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
              '<td style="padding:0"><b>{point.y:.0f}</b></td></tr>',
            footerFormat: '</table>',
            shared: true,
            useHTML: true
          },
          plotOptions: {
            column: {
              pointPadding: 0.2,
              borderWidth: 0
            }
          },
          series: data.chart_data
        });
      )


    $(element).tab('show')
    return false

  updateHash: (newHash) ->
    window.location.hash = newHash
    window.scrollTo(0,0)