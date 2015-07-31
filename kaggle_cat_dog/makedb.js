var fs = require("fs");
var vm = require("vm");
function execute(path) {
    var code = fs.readFileSync(path, 'utf-8');
    vm.runInThisContext(code, path);
};

var exec = require('child_process').exec;
var run = function (command, callback){
    exec(command, function(error, stdout, stderr){
        if ( callback !== undefined) {
            callback(stdout, stderr);
        }
    });
};

// var cmd = "convert /tmp/r2.jpg -thumbnail 256x256^ -gravity center -extent 256x256 " + fileName;

var dogNumber = 12500;
var catNumber = 12500;


var convertImages = function(seq, currentTarget) {
  if ( currentTarget === "dog" ) {
    if ( seq >= dogNumber) {
      seq = 0;
      currentTarget = "cat"
    }
  } else if ( currentTarget === "cat" ) {
    if ( seq >= catNumber ) {
      return;
    }
  } else {
    return;
  }

  var src = "./train/" + currentTarget + "." + seq + ".jpg"
  var dst = "./samples/" + currentTarget + "_" + seq + ".png" 
  var cmd = "convert " + src + " -thumbnail 128x128^ -gravity center -extent 128x128 PNG32:" + dst;

  console.log("==>" + cmd)
  run(cmd, function(){
    seq ++;
    convertImages(seq, currentTarget)
  });
}

convertImages(0, "dog")

