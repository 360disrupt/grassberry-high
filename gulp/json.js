'use strict';

var gulp = require('gulp');

var paths = gulp.paths;

var $ = require('gulp-load-plugins')({
  pattern: ['gulp-*', 'main-bower-files', 'uglify-save-license', 'del']
});

gulp.task('json_tmp', function () {
  return gulp.src(paths.src + '/**/*.json')
    .pipe(gulp.dest(paths.tmp + '/serve/'));
});

gulp.task('json', function () {
  return gulp.src(paths.src + '/**/*.json')
    .pipe(gulp.dest(paths.dist + '/'));
});