require("coffee-script");

//
// Load all the plugin modules
module.exports = {
  "sauron-github-commits": require('./sauron-github-commits'),
  "travis-ci": require('./travis-ci'),
  "timeline": require('./timeline'),
  "rss": require('./rss'),
  "app-sales": require('./app-sales'),
  "user-activity": require('./user-activity')
};