fs = require('fs')
jsonfile = require('jsonfile')
mkdirp = require('mkdirp')

readDir = (path) ->
  return new Promise (resolve, reject) ->
    fs.readdir path, (err, items) ->
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

saveDiffList = (diffList, libName) ->
  path =
    "../storage/#{libName}/#{libName}.json"

  console.log(path)
  
  return new Promise (resolve, reject) ->
    jsonfile.writeFile path, diffList, (err) ->
      if err
        reject(err)
      else
        resolve()
        
getSavedDiffList = (libName) ->
  path =
    "../storage/#{libName}/#{libName}.json"

  return new Promise (resolve, reject) ->
    jsonfile.readFile path, (err, diffList) ->
      if err
        reject(err)
      else
        resolve(diffList)
    
  

module.exports.getSavedDiffList = getSavedDiffList
module.exports.readDir = readDir
module.exports.readFile = readFile
module.exports.saveDiffList = saveDiffList