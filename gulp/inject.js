'use strict';

var gulp = require('gulp');

var paths = gulp.paths;

var $ = require('gulp-load-plugins')();

var wiredep = require('wiredep').stream;


gulp.task('templateCache', ['inject'] , function() {
  var partialsInjectFile = gulp.src(paths.tmp + '/partials/templateCacheHtml.js', { read: false });
  var partialsInjectOptions = {
    starttag: '<!-- inject:partials -->',
    ignorePath: paths.tmp,
    addRootSlash: false
  };
  console.log("finished template cache");
  return gulp.src(paths.tmp + '/serve/index.html')
    .pipe($.inject(partialsInjectFile, partialsInjectOptions))
    .pipe(gulp.dest(paths.tmp + '/serve/'));
});

gulp.task('inject', ['styles', 'scripts-frontend'], function () {

  var injectStyles = gulp.src([
    paths.tmp + '/serve/frontend/**/*.css',
    '!' + paths.tmp + '/serve/frontend/vendor.css'
  ], { read: false });

  var injectScripts = gulp.src([
    '{' + paths.src + ',' + paths.tmp + '/serve}/frontend/**/*.js',
    '!' + paths.src + '/frontend/**/*.spec.js',
    '!' + paths.src + '/frontend/**/*.mock.js'
  ]).pipe($.angularFilesort());

  var injectOptions = {
    ignorePath: [paths.src, paths.tmp + '/serve'],
    addRootSlash: false
  };

  var wiredepOptions = {
    directory: 'bower_components',
    exclude: [/bootstrap-sass-official/, /bootstrap\.css/, /bootstrap\.css/, /foundation\.css/]
  };

  return gulp.src(paths.src + '/*.html')
    .pipe($.inject(injectStyles, injectOptions))
    .pipe($.inject(injectScripts, injectOptions))
    .pipe(wiredep(wiredepOptions))
    .pipe(gulp.dest(paths.tmp + '/serve'));


});
