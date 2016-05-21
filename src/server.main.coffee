# lib dependencies
{ Server } = require('ws')
DiffHandler = require('./utility/server.diff-handler')
StorageController = require('./utility/storage.controller')
RandomKeyGenerator = require('./utility/random-key.generator')

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

server.broadcastDiffModules = (key, data) ->
  ## doc only for doc module in future
  request =
    key: key
    libV1PathDoc: data.libV1Path + '/doc'
    libV2PathDoc: data.libV2Path + '/doc'
    libV1PathSrc: data.libV1Path + '/src'
    libV2PathSrc: data.libV2Path + '/src'

  for module in server.clients
    if module.type in ['documentation', 'code', 'fat model code']
      module.send(JSON.stringify(request))


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

    if module.type in ['documentation', 'code', 'fat model code']
      diffModulesCount++

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
  key = RandomKeyGenerator.makeKey()
  DiffHandler.addRequestedDiffList(key, module)

  server.broadcastDiffModules(key, data)

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

## test-function :)
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
  DiffHandler.pushDiff(data.key, data.diffList)
  
  if DiffHandler.getRequestedDiffListLength(data.key) == diffModulesCount
    diffs = DiffHandler.getRequestedDiffList(data.key)
    recipient = DiffHandler.getRequestedDiffListRecipient(data.key)

    recipient
      .send(JSON.stringify(diffs))
    DiffHandler.removeRequestedDiffList(key)

    #need to add diff save
    

pushModel = (module, data) ->
  ## diff machine function.

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
