#----------------------------------- HELPER FUNCTIONS --------------------------------------------------------
exports.toArray = (source) ->
  # console.log "source #{source.length} ", source
  array = new Array(source.length)
  i = 0
  while i < source.length
    array[i] = source[i]
    ++i
  return array

exports.toUInt8Array = (source) ->
  # console.log "source #{source.length} ", source
  uint8Array = new Uint8Array(source.length)
  i = 0
  while i < source.length
    uint8Array[i] = source[i]
    ++i
  return uint8Array
