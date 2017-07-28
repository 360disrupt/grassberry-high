angular.module("myChartService", ['websockets', 'mySensorService', 'matchmedia-ng', 'ngResource']).service("chartService", ($http, $rootScope, $state, $cookies, $q, $log, $window, lodash, chatSocket, sensorService, MHZ16ChartScaffold, HDC1000ChartScaffold, matchmedia) ->
  self = @
  HISTORY_LENGTH = 30
  @.chambers = []

#================================================== HELPERS ================================
#------------------------------------- X/Y Axes, Timescale ----------------------------------------
  @.setChartTimescale = (chart, scale)->
    chart.scale = scale
    chart.options.scales.xAxes[0].scaleLabel.labelString = "Time (#{scale})"
    return

  @.setChartLabel = (chamber)->
    for chart in chamber.charts
      chart.options.tooltips = {
        callbacks: {
          title: (tooltipItem, data)->
            return "Date/Time:" + moment(tooltipItem[0].xLabel).format('HH:mm:ss')
          label: (data, info)->
            return "#{info.datasets[data.datasetIndex].label}: #{data.yLabel.toFixed(2)}"

        }
      }
    return

  @.adjustScale = (chart, index, history)->
    min = lodash.minBy(history, 'y').y
    max = lodash.maxBy(history, 'y').y
    if max - min > 500
      stepSize = 100
    else if max - min > 250
      stepSize = 50
    else if max - min > 50
      stepSize = 10
    else if max - min > 25
      stepSize = 5
    else if max - min > 5
      stepSize = 1
    else if max - min > 2.5
      stepSize = 0.5
    else
      stepSize = 0.1

    if chart.options.scales.yAxes[index].ticks.stepSize != stepSize
      # console.info "Adjusted step size from #{chart.options.scales.yAxes[index].ticks.stepSize} max #{max} , min #{min}, diff: #{max-min} to stepSize #{stepSize}"
      chart.options.scales.yAxes[index].ticks.stepSize = stepSize
    return null

#=============================== RESPONSIVE CHARTS ========================
  @.showHideYAxis = (value)->
    for chamber in @.chambers
      for chart in chamber.charts
        for yAxis in chart.options.scales.yAxes
          yAxis.display = value
        for xAxis in chart.options.scales.xAxes
          xAxis.display = value

  @.determineMode = ()->
    if matchmedia.is '(max-width: 418px)'
      mode = 'mobile'
    else
      mode = 'desktop'
    return mode

  @.checkDisplayYAxis = ()->
    lastMode = mode
    mode = @.determineMode()
    if lastMode != mode
      switch mode
        when 'mobile'
          @.showHideYAxis false
        when 'desktop'
          @.showHideYAxis true
    return

  angular.element($window).on 'resize', ->
    self.checkDisplayYAxis()
    return

  mode = @.determineMode()


#================================================== CHARTS INIT ================================
#------------------------------------- Build Scaffolds ----------------------------------------
  @.getChartScaffolds = (callback)->
    scaffolds = {}
    MHZ16ChartScaffold.get (mhz16Scaffold)->
      scaffolds.mhz16 = mhz16Scaffold
      HDC1000ChartScaffold.get (hdc1000Scaffold)->
        scaffolds.hdc1000 = hdc1000Scaffold
        return callback scaffolds

  @.buildCharts = (chamber, callback)->
    @.getChartScaffolds (scaffolds)->
      #create a chart for each sensor id (sensors with multiple devices are merged into one chart)
      for activeSensor in chamber.activeSensors
        switch activeSensor.model
          when 'mhz16'
            chamber.charts.push scaffolds.mhz16
          when 'hdc1000'
            chamber.charts.push scaffolds.hdc1000
          else
            return callback "No chartscaffold #{activeSensor.model}"

        currentChart = chamber.charts[chamber.charts.length-1]
        currentChart.sensor = activeSensor._id

        self.setChartTimescale currentChart, 'seconds'
        #create a graph inside the chart for each detector
        for detector in activeSensor.detectors
          detectorId = activeSensor._id + detector.type
          currentChart.activeDetectors.push detectorId
          currentChart.data.push []
          series = detector.name || detector.label
          currentChart.series.push series

      return callback()


  @.initCharts = (chamber)->
    chamber.charts = []
    @.buildCharts chamber, ()=>
      @.setChartLabel chamber
      @.chambers.push chamber
      # console.log "chamber", chamber
      @.checkDisplayYAxis()
      return

#================================================== CHARTS UPDATES ================================
#------------------------------------- Update Chart Timescale ----------------------------------------
  @.updateSensorTimeUnit = (chart, newTimeUnit)->
    sensorService.updateSensorTimeUnit(chart.sensor, newTimeUnit).then (sensorData)->
      self.updateChartValues sensorData, true if sensorData?
      self.setChartTimescale chart, newTimeUnit
      return

  @.updateChartValues = (sensorData, overwriteChart)->
    # _.filter chambers, (item)->
    #   return item.charts.parent === sensorData._id
    for chamber in @.chambers
      if chamber.charts? && ( chamber.stream == true || overwriteChart == true)
        for chart in chamber.charts
          chartValuesCopy = JSON.parse JSON.stringify chart.data #works with a copy otherwise chartjs redraws the chart on each new value
          for detector in sensorData.detectors
            detectorId = sensorData._id + detector.type
            index = chart.activeDetectors.indexOf(detectorId)
            if index != -1 #sensor & detector is active in this chamber
              chartValuesCopy[index] = detector.history
              if chart.scale != sensorData.timeUnit
                self.setChartTimescale chart, sensorData.timeUnit
              self.adjustScale chart, index, chartValuesCopy[index]
          chart.data = JSON.parse JSON.stringify chartValuesCopy
    return

#=============================== CRUD ================================
#=============================== WEBSOCKETS ================================
  $rootScope.$on "socket:sensorData", (event, message) ->
    # console.info "received sensor data", message.payload
    self.updateChartValues message.payload
    return

#////////////////////////////////////////////////////////////////////
  return
)
.factory 'MHZ16ChartScaffold', ($resource) ->
  return $resource('./frontend/main/services/mhz-16-chart-scaffold.json')
.factory 'HDC1000ChartScaffold', ($resource) ->
  return $resource('./frontend/main/services/hdc1000-chart-scaffold.json')

