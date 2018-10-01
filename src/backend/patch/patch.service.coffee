inspect = require('util').inspect
chalk = require('chalk')

async = require('async')

outputService = require("../output/output.service.js")
outputSeeds = require("../seed/outputs.seed.json")

exports.addOutputs = (callback)->
  async.eachSeries outputSeeds, (upsertOutput, next)->
    outputService.upsertOutput upsertOutput, next
  , callback