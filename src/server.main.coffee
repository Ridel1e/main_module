# lib dependencies
{ Server } = require('ws')
CommandParser = require('./utility/server.command-parser')
DiffHandler = require('./utility/server.diff-handler')

# init server and server functions
server = new Server({ port: 8080 });

server.broadcastDiffModules = (data) ->
  for client in server.clients
    client.send(data) if client.type == 'diffFind'
##

## shit code chunk
receivedDiffs = []
diffModuleCount = 0
waitingRequestInterface = undefined
##

serverEvents = (client) ->
  console.log('module connected')
  client.type = 'diffFind'
  diffModuleCount++

  client.on('message', (message) ->
    console.log('received: %s', message)

    event = JSON.parse(message)

    # simple command handler. Need refactor
    switch event.type
      when 'moduleType'
        client.type = event.parameters
        console.log("new module type is #{client.type}")

        diffModuleCount--

      when 'addLib'
        # need to create directory with files
        createDirectory()

      when 'pushDiff'
        receivedDiffs.push(event.parameters)

        if receivedDiffs.length == diffModuleCount
          console.log('All diffs received')
          outputDiffs = DiffHandler.handleDiffs(receivedDiffs)

          waitingRequestInterface.send(JSON.stringify(outputDiffs))

      when 'getDiff'
        console.log('response pending...')
        waitingRequestInterface = client

        # need to add file uploading
        filesPath =
          libDocumentationV1Path : '/class_main1.xml'
          libDocumentationV2Path : '/class_main2.xml'
          libSourceV1Path : 'some/path'
          libSourceV2Path : 'some/path'


        server
          .broadcastDiffModules(JSON.stringify(filesPath))

      else
        console.log('undefined command')
  )

server.on('connection', serverEvents)