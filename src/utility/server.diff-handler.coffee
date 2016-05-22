_ = require 'lodash'


diffStorage = {}

addRequestedDiffList = (key, recipient, libName) ->
  diffStorage[key] =
    diffs: []
    recipient: recipient
    libName : libName

  return

pushDiff = (key, diff) ->
  diffStorage[key]
    .diffs
    .push(diff)

getRequestedDiffListLength = (key) ->
  return diffStorage[key].diffs.length

getRequestedDiffList = (key) ->
  return handleDiffs(diffStorage[key].diffs)

getRequestedDiffListLibName = (key) ->
  return diffStorage[key].libName

getRequestedDiffListRecipient = (key) ->
  return diffStorage[key].recipient

removeRequestedDiffList = (key) ->
  delete diffStorage[key]

handleDiffs = (diffs) ->
  outputDiffs = []
  outputDiffs = outputDiffs.concat diff for diff in diffs

  return _.uniqWith outputDiffs, _.isEqual

module.exports.addRequestedDiffList = addRequestedDiffList
module.exports.getRequestedDiffList = getRequestedDiffList
module.exports.getRequestedDiffListLength = getRequestedDiffListLength
module.exports.getRequestedDiffListLibName = getRequestedDiffListLibName
module.exports.getRequestedDiffListRecipient = getRequestedDiffListRecipient
module.exports.removeRequestedDiffList = removeRequestedDiffList
module.exports.pushDiff = pushDiff
