var git = require('git-rev')
fs = require('fs');

var str_to_write = "";

function getCommitInfo() {
  git.short(function (str_short) {
    str_to_write = str_to_write +"Commit short Id: " + str_short +"\n";
    git.long(function (str_long) {
      str_to_write = str_to_write + "Commit long Id: " + str_long +"\n";
      git.branch(function (branch) {
        str_to_write = str_to_write + "Commit branch: " + branch +"\n";
        fs.writeFile('git_revision_info.txt', str_to_write, function (err) {
          if (err) return console.log(err);
        })
      })
    })
  })
}

getCommitInfo();


