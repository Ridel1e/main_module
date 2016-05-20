fs = require('fs')
jsonfile = require('jsonfile')
mkdirp = require('mkdirp')

readDir = (path) ->
  return new Promise (resolve, reject) ->
    fs.readdir path, 'utf8', (err, items) ->
      if items
        resolve(items)
      else
        reject(err)

readFile = (path) ->
  return new Promise (resolve, reject) ->
    fs.readFile path, 'utf8', (err, data) ->
      if data
        resolve(data)
      else
        reject(err)

writeDiff = (path) ->
  

module.exports.readDir = readDir
module.exports.readFile = readFile