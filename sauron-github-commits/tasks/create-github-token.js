var GitHubApi = require('github');
var github = new GitHubApi({ "version": "3.0.0" });

var prompt = require('../lib/prompt');

//
// Start the prompt
//
prompt.start();

//
// Get two properties from the user: username and password
//
prompt.get([{
    name:'password',
    hidden: true,
    validator: function (value, next) {
      setTimeout(next, 200);
    }
  }], function (err, result) {
  //
  // Log the results.
  //
  console.log('Command-line input received:');
  console.log('  password: ' + result.password);
});

github.authorization.create({
  scopes: [ "repo" ],
  note:   "Authorization for sauron server"
}, function(err, auth) {
  console.log("Looks good!\n\n", auth);
});
