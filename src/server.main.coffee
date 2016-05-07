# lib dependencies
{ Server } = require('ws')
ServerCommandsController = require('./utility/server.commands-controller')
DiffHandler = require('./utility/server.diff-handler')

filesPath =
  libDocumentationV1Path : '/class_main1.xml'
  libDocumentationV2Path : '/class_main2.xml'
  libSourceV1Path : 'some/path'
  libSourceV2Path : 'some/path'

# init server and server functions
server = new Server({ port: 8080 });

server.broadcast = (data, currentClient) ->
  for client in server.clients
    client.send(data) if client != currentClient

receivedDiffs = []
interfaceModules = []

# init server commands
#serverCommandsController = new ServerCommandsController()
#
#serverCommandsController.addCommand('/getDiffs', server.broadcast)
#serverCommandsController.addCommand('/diff', (message) ->
#  receivedDiffs.push JSON.parse message
#)


serverEvents = (ws) ->
  console.log 'module connected'

  ws.on 'message', (message) ->
    console.log 'received: %s', message

    if message == '/getDiffs'
      interfaceModules.push(ws)
      server
        .broadcast(JSON.stringify(filesPath), ws)
    else
      receivedDiffs.push JSON.parse message

    if receivedDiffs.length == server.clients.length - 1
      console.log 'all diff has been received'
      outputDiffs = DiffHandler.handleDiffs(receivedDiffs)

      for client in interfaceModules
        client.send(JSON.stringify(outputDiffs))



server.on('connection', serverEvents)
