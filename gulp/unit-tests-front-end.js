'use strict';

var gulp = require('gulp');

var $ = require('gulp-load-plugins')();

var wiredep = require('wiredep');

var paths = gulp.paths;

function runTestsFE (singleRun, done) {
  var bowerDeps = wiredep({
    directory: 'bower_components',
    exclude: ['bootstrap-sass-official'],
    dependencies: true,
    devDependencies: true
  });

  var testFiles = bowerDeps.js.concat([
    paths.tmp + '/serve/frontend/**/*.js',
    paths.specs + '/frontend/**/*.spec.js',
    paths.specs + '/frontend/**/*.mock.js'
  ]);

  gulp.src(testFiles)
    .pipe($.karma({
      configFile: 'karma.conf.js',
      action: (singleRun)? 'run': 'watch'
    }))
    .on('error', function (err) {
      // Make sure failed tests cause gulp to exit non-zero
      throw err;
    });
}

gulp.task('testFE', ['scripts-frontend', 'scripts-specs'], function (done) { runTestsFE(true /* singleRun */, done) });
gulp.task('testFE:auto', ['watch-scripts'], function (done) { runTestsFE(false /* singleRun */, done) });
