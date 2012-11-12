
feedparser = require "feedparser"
async      = require "async"
request    = require "request"
{CronJob}  = require "cron"

exports.init = (webhook, pluginConfig, done) ->
  done null, pluginConfig

exports.properties = (state, done)->
  done null, [
    name: "title", prompt: "Title", link: "article"
  ,
    name: "date", prompt: "Published", render: "date"
  ]

exports.links = (state, done)->
  done null, [
    rel: "article", prompt: "Article"
  ]

exports.run = (state, feed)->
  feeds = state?.feeds

  async.forEach feeds, (rssFeed, next) ->
    fetchFeeds = ()->
      console.log "Updating feed from #{rssFeed}"
      # TODO cache the results
      request rssFeed, (error, response, body)->
        feedparser.parseString(body)
          .on "article", (article)->
            date = new Date(article.date)
            feed.emit encodeURIComponent(article.link), {
              article: article.link
              title: article.title
              date: date
            }
          

    # Initial fetch
    fetchFeeds()

    # TODO config how often this fetches
    next null, new CronJob "*/1 * * * *", fetchFeeds, null, true
