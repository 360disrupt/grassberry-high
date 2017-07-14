'use strict';
var gulp = require('gulp');
var paths = gulp.paths;
var fs = require('fs');
var mkdirp = require('mkdirp');

gulp.task('createVersionFile', function(cb){
  mkdirp(paths.dist, function(err){
    fs.writeFile(paths.dist + '/version.txt', (new Date()).toISOString(), cb);
  });
});

gulp.task('createVersionFile_tmp', function(cb){
  fs.writeFile(paths.tmp + '/serve/version.txt', (new Date()).toISOString(), cb);
});