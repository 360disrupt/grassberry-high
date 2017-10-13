'use strict';
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var paths = gulp.paths;
var argv = require('yargs').argv

gulp.task('testBE', ['watch-backend'], function () {

  return gulp.src(paths.specs + '/backend/**/*.spec.js')
    .pipe($.jasmine({verbose: true}));
});

gulp.task('testBECodeship', function () {

  return gulp.src(paths.specs + '/backend/**/*.spec.js')
    .pipe($.jasmine({verbose: true}));
});

'use strict';

var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var paths = gulp.paths;


gulp.task('testBElimited', ['watch-backend-limited'], function () {
  var limitedPath = paths.specs + '/backend/';
  var path = argv.p || '*';


  limitedPath += path;
  limitedPath += '*.spec.js';

  console.log(limitedPath);
  return gulp.src([limitedPath])
    .pipe($.jasmine({verbose: true}));
});