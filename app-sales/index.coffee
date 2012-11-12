# GitHub commit stream plugin
#
# Intended to aggregate commits from a set of related repositories

async      = require 'async'

exports.init = (webhook, pluginConfig, done) ->
  done()

exports.properties = (state, done)->
  done null, [
    name: "country", prompt: "Country"
  ,
    name: "amount", prompt: "Amount"
  ,
    name: "experiment", prompt: "Experiment"
  ,
    name: "device", prompt: "Device"
  ,
    name: "date", prompt: "When", render: "date"
  ]

exports.links = (state, done)->
  done null, []

exports.webhook = (state, req, feed, done)->
  async.forEach (req.body or []), ((sale, next)->
    sale.date = (new Date(sale.timestamp)).toISOString()
    feed.emit sale.transaction, sale, next
  ), done
