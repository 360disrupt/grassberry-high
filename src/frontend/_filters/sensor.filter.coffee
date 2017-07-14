angular.module 'tsd.sensor', []
  .filter 'sensorFilter', () ->
    return (input, sensorType)->
      # console.log "input #{input}", sensorType
      if !input?
        return null
      switch sensorType
        when 'water'
          switch input
            when "2,00"
              return 'Wet'
            when "1,00"
              return 'Moist'
            when "0,00"
              return 'Dry'
            else
              return input

        else
          return input