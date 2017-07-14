angular.module 'tsd.unitFilter', []
  .filter 'unitFilter', () ->
    return (unit, input)->
      switch unit
        when 'temperature'
          map = { celsius: 'C', fahrenheit: 'F'}
          return map[input] || input
        else
          return input