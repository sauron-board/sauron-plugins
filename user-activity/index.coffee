# User list of user activity
#

exports.init = (webhook, pluginConfig, done) ->
  done()

exports.properties = (state, done)->
  done null, [
    name: "display-name", prompt: "Name", link: "account"
  ,
    name: "date", prompt: "Last Logged In", render: "date"
  ]

exports.links = (state, done)->
  done null, [
    rel: "account", prompt: "Account"
  ]

exports.handleUserAction = (state, action, user, feed, done)->
  return done() if action isnt "login"
  obj =
    'display-name': user?.displayName or user?.username
    date: (new Date).toISOString()
    account: user?.profileUrl

  feed.emit user?.id, obj, done
