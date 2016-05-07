_ = require 'lodash'

handleDiffs = (diffs) ->
  outputDiffs = []
  outputDiffs = outputDiffs.concat diff for diff in diffs

  return _.uniqWith outputDiffs, _.isEqual

module.exports.handleDiffs = handleDiffs