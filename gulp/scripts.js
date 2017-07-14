'use strict';

var gulp = require('gulp');
var gutil = require('gulp-util');
var paths = gulp.paths;

var $ = require('gulp-load-plugins')();

gulp.task('scripts-frontend', function () {
  return gulp.src([paths.src + '/{frontend, xxx}/**/*.coffee', '!' + paths.src + '/*.spec.coffee'])
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .on('error', function handleError(err) {
      console.error(err.toString());
      gutil.beep();
      this.emit('end');
    })
    .pipe(gulp.dest(paths.tmp + '/serve/'))
    .pipe($.size())
});


gulp.task('scripts-backend', function () {
  return gulp.src([paths.src + '/{backend, xxx}/**/*.coffee', paths.src + '/server.coffee', '!' + paths.src + '/**/*.spec.coffee'])
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.sourcemaps.init())
    .pipe($.coffee())
    .on('error', function handleError(err) {
      console.error(err.toString());
      gutil.beep();
      this.emit('end');
    })
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest(paths.tmp + '/serve/'))
    .pipe($.size())
});

gulp.task('scripts-specs', function () {
  //Front end specs
  gulp.src([paths.src + '/**/*.spec.coffee', '!' + paths.src + '/backend/*.spec.coffee', '!' + paths.src + '/backend/*.spec-settings.coffee'])
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.coffee()).on('error', gutil.log)
    .on('error', function handleError(err) {
      console.error(err.toString());
      gutil.beep();
      this.emit('end');
    })
    .pipe($.rename({dirname: ''}))
    .pipe(gulp.dest(paths.specs + '/frontend/'))
    .pipe($.size())

  //backend specs
  return gulp.src([paths.src + '/backend/**/*.spec.coffee', paths.src + '/backend/**/*.spec-settings.coffee'])
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .on('error', function handleError(err) {
      console.error(err.toString());
      gutil.beep();
      this.emit('end');
    })
    .pipe($.rename({dirname: ''}))
    .pipe(gulp.dest(paths.specs + '/backend/'))
    .pipe($.size())
});