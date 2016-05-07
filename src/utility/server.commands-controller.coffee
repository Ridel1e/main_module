class ServerCommandsController
  constructor : () ->
    @commands = {}

  addCommand : (command, func) ->
    @commands[command] = func

  getCommands : () ->
    console.log(@commands)

module.exports = ServerCommandsController