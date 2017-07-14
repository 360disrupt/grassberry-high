inspect = require('util').inspect
chalk = require('chalk')
debugSocketIo = require('debug')('socketio')

socketIoReceiver = require('./socket-io-receiver.js')

socket = null
myIo = null

exports.getIo = () ->
  return myIo

exports.initSocketListener = (io)->
  myIo = io
  io.on 'connection', (newSocket) ->
    debugSocketIo 'user connected'

    socket = newSocket

    # socket.on 'cashier', (payLoad) ->
    #   socketIoReceiver.forwardMessage 'cashier', payLoad

    socket.on('disconnect', ()->
      debugSocketIo 'user disconnected'
      return null
    )
    return null
  return null

exports.sendMessage = (messageType, message) ->
  myIo.emit(messageType, message) if myIo?
  return null

exports.sendLog = (type, message) ->
  myIo.emit(type, message) if myIo?
  return null