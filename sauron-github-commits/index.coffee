# GitHub commit stream plugin
#
# Intended to aggregate commits from a set of related repositories

async      = require 'async'
GitHubAPI  = require 'github'

exports.init = (webhook, pluginConfig, done) ->
  repos = pluginConfig?.repos

  github = new GitHubAPI({ "version": "3.0.0" })
  github.authenticate
    type:  "oauth"
    token: pluginConfig?.githubToken

  async.map repos, (repo, callback) ->
    [owner, repoName] = repo.split /\//

    github.repos.getHooks
      user: owner
      repo: repoName
    , (err, res) ->
      if err
        callback(err)
        return
      hooks = (hook for hook in res when hook.config.url is webhook)
      if hooks.length > 0
        hook = hooks[0]
        github.repos.updateHook
          user: owner
          repo: repoName
          name: 'web'
          id: hook.id
          config:
            "url": webhook,
            "content_type": "json"
          events: [ "push" ]
          active: true
        , (err, res) ->
          callback(null, res)

      else
        github.repos.createHook
          user: owner
          repo: repoName
          name: 'web'
          config:
            "url": webhook,
            "content_type": "json"
          events: [ "push" ]
          active: true
        , (err, res) ->
          callback(null, res)

  , (err, result) ->
    console.log "finishing...", err
    pluginConfig.hooks = result
    done(err, pluginConfig)

exports.properties = (state, done)->
  done null, [
    name: "sha", prompt: "What", link: "commit"
  ,
    name: "author", prompt: "Who", link: "author-email"
  ,
    name: "message", prompt: "Why"
  ,
    name: "date", prompt: "When", render: "date"
  ]

exports.links = (state, done)->
  done null, [
    rel: "commit", prompt: "Commit"
  ,
    rel: "author-email", prompt: "Author Email"
  ]

exports.webhook = (state, req, feed, done)->
  async.forEach (req.body?.commits or []), ((commit, next)->
    feed.emit commit.id, {
      sha: commit.id.substring(0, 10)
      author: commit.author.name
      "author-email": commit.author.email
      message: commit.message
      date: commit.timestamp
      commit: commit.url
    }, next
  ), done
