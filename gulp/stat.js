var fs = require('fs');
var gulp = require('gulp');

gulp.task('stat', ['pack'], function(cb){
  fs.readdir('./', function(err, files){
    files = files.filter(function(file){
      return file.match(/.*\.tar\.gz/);
    });
    console.log("Stats for file", files[0]);
    fs.stat( './' + files[0], function(err, stat){
      console.log("Size:  ",stat.size);
      return cb()
    });
  });
});