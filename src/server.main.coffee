# lib dependencies
{ Server } = require('ws')
DiffHandler = require('./utility/server.diff-handler')
StorageController = require('./utility/storage.controller')

## initializations
server = new Server({ port: 8080 })
server.generateResponse = (status, data) ->
  switch status
    when 'success'
      return {
        status: status
        type: arguments[0]
        data: data
      }
    when 'error'
      return {
        status: status
        message: data
      }

server.broadcastDiffModules = (data) ->
  for client in server.clients
    if client.type in ['documentation', 'code', 'fat model code']
      client.send(data)


moduleTypes = ['interface', 'documentation', 'code', 'fat model code', 'source migrate', 'diff machine']
diffModulesCount = 0
commands = undefined

# interface
initCommands = () ->
  commands =
    getDiffs: getDiffs
    getDir: getDir
    getDirs: getDirs
    getFile: getFile
    getGuitarDiff: getGuitarDiff
    hasCommand: hasCommand
    pushDiff: pushDiff
    pushModel: pushModel
    setModuleType: setModuleType

## command functions
setModuleType = (module, data) ->
  if moduleTypes.indexOf(data) > -1
    module.type = data

    message = "now module type is #{data}"
    response = server
      .generateResponse('success', message, 'setType')

    module
      .send(JSON.stringify(response))
  else
    message: 'module type is undefined'
    response = server
      .generateResponse('error', message)

    module.send(JSON
      .stringify(response))

getDiffs = (module, data) ->
  console.log('getDiffs')
  ##

getDir = (module, data) ->

  StorageController
    .readDir("../storage#{data}")
    .then (items) ->
      response = server
        .generateResponse('success', items, 'dir')

      module.send(JSON
        .stringify(response))

    .catch (err) ->
      console.log(err)

      message = "can't read libs dir"
      response = server
        .generateResponse('error', message)

      module.send(JSON
        .stringify(response))

getDirs = (module) ->

  StorageController
    .readDir("../storage")
    .then (items) ->
      response = server
        .generateResponse('success', items, 'dirs')

      module.send(JSON
        .stringify(response))

    .catch (err) ->
      console.log(err)

      message = "can't read libs dirs"
      response = server
        .generateResponse('error', message)

      module.send(JSON
        .stringify(response))


getFile = (module, data) ->

  StorageController
    .readFile("../storage#{data}")
    .then (data) ->
      response = server
        .generateResponse('success', data, 'file')

      module.send(JSON
        .stringify(response))

      .catch (err) ->
        console.log(err)

        message = "can't read file"
        response = server
          .generateResponse('error', message)

        module.send(JSON
          .stringify(response))


getGuitarDiff = (module) ->

  StorageController
    .readFile("../storage/guitar/guitar.json")
    .then (data) ->
      response = server
        .generateResponse('success', data, 'file')

      module.send(JSON
        .stringify(response))

    .catch (err) ->
      console.log(err)

      message = "can't read file"
      response = server
      .generateResponse('error', message)

      module.send(JSON
      .stringify(response))


  module.send()
  ##

hasCommand = (command) ->
  return true if commands[command]

pushDiff = (module, data) ->
  ##

pushModel = (module, data) ->
  ##

## call initCommand to initialize
initCommands()
    
## !initializations


## Server events


serverEvents = (client) ->
  console.log('new module connected')

  client.on 'message', (message) ->
    console.log('received: %s', message)

    event = JSON.parse(message)

    if commands.hasCommand(event.cmd)
      commands[event.cmd](client, event.data)
    else
      client.send(JSON
        .stringify(error: 'command not found'
      ))

server.on('connection', serverEvents)
    
## !server events

######################################

#saveLibDiff = (fileName, diff) ->
#
#  mkdirp("./file_storage/#{fileName}", (err) ->
#    console.log(err)
#  )
#
#  fileFullName = "./file_storage/#{fileName}/#{fileName}"
#
#  jsonfile.writeFile(fileFullName, diff, (err) ->
#    console.log(err)
#  )
##

### shit code chunk
#receivedDiffs = []
#waitingRequestInterface = undefined
###
#
#serverEvents = (client) ->
#  console.log('module connected')
##  client.type = 'diffFind'
##  diffModuleCount++
#
#  client.on('message', (message) ->
#    console.log('received: %s', message)
#
#    event = JSON.parse(message)
#
#    # simple command handler. Need refactor
#    switch event.type
#      when 'moduleType'
#        client.type = event.parameters
#        console.log("new module type is #{client.type}")
#
#        diffModuleCount--
#
#      when 'addLib'
#        # need to create directory with files
#        createDirectory()
#
#      when 'pushDiff'
#        receivedDiffs.push(event.parameters)
#
#        if receivedDiffs.length == diffModuleCount
#          console.log('All diffs received')
#          outputDiffs = DiffHandler.handleDiffs(receivedDiffs)
#
#          saveLibDiff(waitingRequestInterface.libName, outputDiffs)
#
#          waitingRequestInterface
#            .client
#            .send(JSON.stringify(outputDiffs))
#
#      when 'getDiff'
#        console.log('response pending...')
#
#        # need refactor
#        splitedLibPath  = event
#          .parameters
#          .libV2Path
#          .split('/')
#
#        libName = splitedLibPath[splitedLibPath.length - 2]
#
#        waitingRequestInterface =
#          client : client
#          libName : libName
#
#        fileFullName = "./file_storage/#{libName}/#{libName}"
#
#        jsonfile.readFile(fileFullName, (err, object) ->
#
#          if !object
#            # need to add file uploading (some shit code chunk again)
#            filesPath =
#              libDocumentationV1Path : event.parameters.libV1Path + '/doc'
#              libDocumentationV2Path : event.parameters.libV2Path + '/doc'
#              libSourceCodeV1Path : event.parameters.libV1Path + '/src'
#              libSourceCodeV2Path : event.parameters.libV2Path + '/src'
#
#            server
#              .broadcastDiffModules (JSON.stringify(filesPath))
#
#          else
#            console.log('repeat')
#            client.send(JSON.stringify(object))
#        )
#
#      else
#        console.log('undefined command')
#  )
#
