angular.module 'tsd.csvExport', ['ngCsv']
  .directive 'csvExport', () ->
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '_directives/csv-export/csv-export.html'
      scope:
        chamber: '='
      link: (scope, element, attrs) ->
        scope.disabled = false
        scope.chartIndex = 0
        flattenObject = (ob) ->
          what = Object.prototype.toString
          toReturn = {}
          for i of ob
            if !ob.hasOwnProperty(i)
              continue
            result = what.call(ob[i])
            if result == '[object Object]' or result == '[object Array]'
              flatObject = flattenObject(ob[i])
              for x of flatObject
                if !flatObject.hasOwnProperty(x)
                  continue
                toReturn[i + '.' + x] = flatObject[x]
            else if result == '[object Date]' || (result == '[object String]' && /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z)/.test ob[i]) #regex ISODate
              toReturn[i] = moment(ob[i]).utcOffset('+0200').format('DD-MM-YYYY')
            else
              toReturn[i] = ob[i]
          toReturn

        scope.getFilename = (filename)->
          filename = scope.chamber.name || ''
          return (filename + ' ' + moment().format('YYYY-MM-DD HH-mm')).trim()

        scope.prepareData = () ->
          table = []

          header1 = []
          header2 = []
          body = []
          column = 0

          for chart in scope.chamber.charts
            for seriesIndex in [0...chart.series.length]
              header1.push chart.series[seriesIndex]
              header1.push ''
              header2.push 'Time'
              header2.push 'Value'
              #building the header
              #body
              for rowIndex in [0...chart.data[seriesIndex].length]
                body.push [] if !body[rowIndex]?
                body[rowIndex][column * 2] = chart.data[seriesIndex][rowIndex].x
                body[rowIndex][column * 2 + 1] = chart.data[seriesIndex][rowIndex].y

              column++

          table.push header1
          table.push header2
          for row in body
            table.push row

          return table

        scope.downloadCsv = () ->
          return scope.prepareData()

        return
    }