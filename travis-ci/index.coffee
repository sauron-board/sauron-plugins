
SITE_PREFIX = "https://travis-ci.org"
SITE_SUFFIX = "/builds"

PREFIX = "https://api.travis-ci.org/repos"
SUFFIX = "/builds.json"

async      = require "async"
request    = require "request"
{CronJob}  = require "cron"

exports.init = (webhook, pluginConfig, done) ->
  done null, pluginConfig

exports.properties = (state, done)->
  done null, [
    name: "result", prompt: "Result", link: "build"
  ,
    name: "duration", prompt: "Duration"
  ,
    name: "message", prompt: "Message"
  ,
    name: "date", prompt: "Finished", render: "date"
  ]

exports.links = (state, done)->
  done null, [
    rel: "build", prompt: "Build"
  ]

exports.run = (state, feed)->
  repos = state?.repos

  async.forEach repos, (repo, next) ->
    fetchBuilds = ()->
      request "#{PREFIX}/#{repo}#{SUFFIX}", (error, response, body)->
        body = JSON.parse body if typeof body is "string"

        async.forEach body, (build)->
          date = new Date(build.started_at)
          feed.emit build.id, {
            result: if build.result is 0 then "Success" else "Failure"
            duration: build.duration or "Incomplete"
            message: build.message
            date: date.toISOString()
            build: "#{SITE_PREFIX}/#{repo}#{SITE_SUFFIX}/#{build.id}"
          }

    # Initial fetch
    fetchBuilds()

    # TODO config how often this fetches
    next null, new CronJob "*/30 * * * *", fetchBuilds, null, true
