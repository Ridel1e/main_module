parseCommand = (message) ->
  if message.indexOf(' ') == -1
    return {
      command : message
      data : ''
    }
  else
    return {
      command : message.substr(0, message.indexOf(' '))
      data : message.substr(message.indexOf(' ') + 1 , message.length)
    }

module.exports.parserCommand = parseCommand