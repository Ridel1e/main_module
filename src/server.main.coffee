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
        type: arguments[2]
        data: data
      }
    when 'error'
      return {
        status: status
        message: data
      }

server.getLibName = (data) ->
  return data.libV1Path.split('/')[1]

server.broadcastDiffModules = (key, data) ->
  ## doc only for doc module in future
  request =
    type: 'request'
    data:
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

## in current implementation server can have only one diff machine
diffMachine = undefined 
##

# interface
initCommands = () ->
  commands =
    getDiffs: getDiffs
    getDir: getDir
    getDirs: getDirs
    getFile: getFile
    hasCommand: hasCommand
    pushDiff: pushDiff
    pushModel: pushModel
    setModuleType: setModuleType

## command functions

## function for set a type of module
setModuleType = (module, data) ->
  if moduleTypes.indexOf(data) > -1
    module.type = data

    if module.type in ['documentation', 'code', 'fat model code']
      diffModulesCount++

    if module.type == "diff machine"
      diffMachine = module

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

# Function that get diffs request and broadcast diff generator modules
getDiffs = (module, data) ->
  libName = server
    .getLibName(data)

  StorageController
    .getSavedDiffList(libName)
    .then (diffList) ->
      response = server
        .generateResponse('success', diffList, 'getDiffs')

      module.send(JSON
        .stringify(response))

    .catch () ->
      key = RandomKeyGenerator.makeKey()
      DiffHandler.addRequestedDiffList(key, module, libName)

      server.broadcastDiffModules(key, data)
  ##

# Function that returns dir content
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

# function that returns all libs folders
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

# function that returns file content
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

hasCommand = (command) ->
  return true if commands[command]

# Function that get diff and push him to personal diff array,
# if array will be full, server send diff list to recipient
pushDiff = (module, data) ->
  DiffHandler.pushDiff(data.key, data.diffList)

  if DiffHandler.getRequestedDiffListLength(data.key) == diffModulesCount
    diffs = DiffHandler.getRequestedDiffList(data.key)
    recipient = DiffHandler.getRequestedDiffListRecipient(data.key)
    libName =  DiffHandler.getRequestedDiffListLibName(data.key)

    # need some refactor
    sendPromise = new Promise (resolve, reject) ->
      response = server
        .generateResponse('success', diffs, 'getDiffs')

      recipient
        .send(JSON.stringify(response))

      resolve()

    sendPromise
      .then () ->
        StorageController.saveDiffList(diffs, libName)

      .then () ->
        DiffHandler.removeRequestedDiffList(key)

      .catch () ->
        console.log(err)

pushModel = (module, data) ->
  request =
    type: 'request'
    data: data

  diffMachine
    .send(JSON.stringify(request))

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
