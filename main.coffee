{ Server } = require('ws')
http = require "http"

server = new Server({ port: 8080 });

#modules = []

server.on 'connection', (ws) ->

  console.log 'module connected'
#  modules.push ws

  ws.on 'message', (message) ->
    console.log 'received: %s', message




