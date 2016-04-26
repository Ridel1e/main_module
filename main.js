// Generated by CoffeeScript 1.10.0
(function() {
  var Server, _, diffs, filesPath, generateOutputDiffs, http, moduleCount, server, sourceMigrateModule;

  Server = require('ws').Server;

  _ = require('lodash');

  http = require("http");

  server = new Server({
    port: 8080
  });

  filesPath = {
    libDocumentationV1Path: '/class_main1.xml',
    libDocumentationV2Path: '/class_main2.xml',
    libSourceV1Path: 'some/path',
    libSourceV2Path: 'some/path'
  };

  moduleCount = 2;

  diffs = [];

  sourceMigrateModule = void 0;

  generateOutputDiffs = function() {
    var diff, i, len, outputDiffs;
    outputDiffs = [];
    for (i = 0, len = diffs.length; i < len; i++) {
      diff = diffs[i];
      outputDiffs = outputDiffs.concat(diff);
    }
    return _.uniqWith(outputDiffs, _.isEqual);
  };

  server.on('connection', function(ws) {
    console.log('module connected');
    ws.send(JSON.stringify(filesPath));
    return ws.on('message', function(message) {
      var outputDiffs;
      console.log('received: %s', message);
      diffs.push(JSON.parse(message));
      if (diffs.length === moduleCount) {
        console.log('all!');
        return outputDiffs = generateOutputDiffs();
      }
    });
  });

}).call(this);

//# sourceMappingURL=main.js.map
