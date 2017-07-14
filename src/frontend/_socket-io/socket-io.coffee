angular.module "websockets", ['btford.socket-io']
  .factory('chatSocket', (socketFactory, $location) ->
    http = $location.protocol()
    slashes = http.concat("://")
    host = slashes.concat($location.host())
    host = host.concat(':'+$location.port())

    # console.log "host", host
    mySocket = socketFactory({
      ioSocket: io(host)
    })
    mySocket.forward('userLog')
    mySocket.forward('adminLog')
    mySocket.forward('userMessage')
    mySocket.forward('system')
    mySocket.forward('sensorData')
    mySocket.forward('eventData')
    mySocket.forward('outputData')

    return mySocket
  )