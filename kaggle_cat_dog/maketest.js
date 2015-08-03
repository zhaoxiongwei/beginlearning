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

var testNumber = 12500;


var convertImages = function(seq) {
  if ( seq > testNumber ) {
    return;
  }

  var src = "./test1/" + seq + ".jpg"
  var dst = "./test/"  + seq + ".png" 
  var cmd = "convert " + src + " -thumbnail 128x128^ -gravity center -extent 128x128 PNG32:" + dst;

  console.log("==>" + cmd)
  run(cmd, function(){
    seq ++;
    convertImages(seq)
  });
}

convertImages(1)

