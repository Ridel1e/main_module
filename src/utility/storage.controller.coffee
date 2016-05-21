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


module.exports.readDir = readDir
module.exports.readFile = readFile