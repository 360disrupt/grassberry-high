angular.module 'tsd.output', []
  .filter 'outputFilter', () ->
    return (input)->
      if input == 1
        return 'on'
      else
        return 'off'