# lib dependencies
{ Server } = require('ws')
jsonfile = require('jsonfile')
mkdirp = require('mkdirp')
DiffHandler = require('./utility/server.diff-handler')


# init server and server functions
server = new Server({ port: 8080 });

server.broadcastDiffModules = (data) ->
  for client in server.clients
    client.send(data) if client.type == 'diffFind'

saveLibDiff = (fileName, diff) ->

  mkdirp("./file_storage/#{fileName}", (err) ->
    console.log(err)
  )

  fileFullName = "./file_storage/#{fileName}/#{fileName}"

  jsonfile.writeFile(fileFullName, diff, (err) ->
    console.log(err)
  )
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

          saveLibDiff(waitingRequestInterface.libName, outputDiffs)

          waitingRequestInterface
            .client
            .send(JSON.stringify(outputDiffs))

      when 'getDiff'
        console.log('response pending...')

        # need refactor
        splitedLibPath  = event
          .parameters
          .libV2Path
          .split('/')

        libName = splitedLibPath[splitedLibPath.length - 2]

        waitingRequestInterface =
          client : client
          libName : libName

        fileFullName = "./file_storage/#{libName}/#{libName}"

        jsonfile.readFile(fileFullName, (err, object) ->

          if !object
            # need to add file uploading (some shit code chunk again)
            filesPath =
              libDocumentationV1Path : event.parameters.libV1Path + '/doc'
              libDocumentationV2Path : event.parameters.libV2Path + '/doc'
              libSourceCodeV1Path : event.parameters.libV1Path + '/src'
              libSourceCodeV2Path : event.parameters.libV2Path + '/src'

            server
              .broadcastDiffModules (JSON.stringify(filesPath))

          else
            console.log('repeat')
            client.send(JSON.stringify(object))
        )

      else
        console.log('undefined command')
  )

server.on('connection', serverEvents)