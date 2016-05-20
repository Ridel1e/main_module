_ = require 'lodash'


diffStorage = {}

addRequestedDiffList = (key, recipient) ->
  diffStorage[key] =
    diffs: []
    recipient: recipient

handleDiffs = (diffs) ->
  outputDiffs = []
  outputDiffs = outputDiffs.concat diff for diff in diffs

  return _.uniqWith outputDiffs, _.isEqual

module.exports.handleDiffs = handleDiffs