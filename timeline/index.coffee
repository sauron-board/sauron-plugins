# User list of user activity
#

exports.init = (webhook, pluginConfig, done) ->
  done null, {value:0}

exports.properties = (state, done)->
  done null, [
    name: "value", prompt: "Value"
  ]

exports.handleUserAction = (state, action, user, feed, done)->
  state.value += switch action
    when "connection"
      1
    when "disconnect"
      -1
    else
      0

  feed.emit "current-users", state, done
