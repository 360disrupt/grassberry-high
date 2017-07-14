'use strict';

var gulp = require('gulp');

var $ = require('gulp-load-plugins')();

var paths = gulp.paths;

gulp.task('watch', ['templateCache', 'images_tmp', 'partials_tmp', 'misc_tmp' , 'json_tmp', 'fonts_tmp', 'createVersionFile_tmp'], function () {
  gulp.watch(paths.src + '/frontend/**/*.json', ['json_tmp']);
  gulp.watch(paths.src + '/frontend/**/*.{jpg,jpeg,png,svg,gif}', ['images_tmp']);
  gulp.watch(paths.src + '/frontend/**/*.scss', ['styles']);
  gulp.watch([
    paths.src + '/**/*.html',
    paths.src + '/frontend/**/*.js',
    paths.src + '/frontend/**/*.coffee',
    'bower.json'
  ], ['templateCache', 'partials_tmp']);
});

gulp.task('watch-backend',['scripts-backend', 'scripts-specs', 'json_tmp', 'misc_tmp'], function () {
  gulp.watch([
    paths.src + '/backend/**/*.coffee',
    paths.src + '/backend/**/*.json'
  ], ['testBE']);
});

gulp.task('watch-backend-limited',['scripts-backend', 'scripts-specs', 'json_tmp', 'misc_tmp'], function () {
  gulp.watch([
    paths.src + '/backend/**/*.coffee',
    paths.src + '/backend/**/*.xml',
    paths.src + '/backend/**/*.json'
  ], ['testBElimited']);
});