{ Server } = require('ws')
_ = require 'lodash'
http = require "http"

server = new Server({ port: 8080 });

# inits
filesPath =
  libDocumentationV1Path : '/class_main1.xml'
  libDocumentationV2Path : '/class_main2.xml'
  libSourceV1Path : 'some/path'
  libSourceV2Path : 'some/path'

moduleCount = 2
diffs = []
# need to write source migrate module hier
sourceMigrateModule = undefined

# functions
generateOutputDiffs = () ->
  outputDiffs = []
  outputDiffs = outputDiffs.concat diff for diff in diffs

  return _.uniqWith outputDiffs, _.isEqual

server.on 'connection', (ws) ->
  console.log 'module connected'
  ws.send JSON.stringify filesPath

  ws.on 'message', (message) ->
    console.log 'received: %s', message
    diffs.push JSON.parse message

    if diffs.length == moduleCount
      console.log 'all!'

      outputDiffs = generateOutputDiffs()
#      sourceMigrateModule.send(JSON.stringify outputDiffs)



