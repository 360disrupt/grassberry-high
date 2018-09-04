'use strict';

var gulp = require('gulp');

var paths = gulp.paths;
var urls = gulp.urls;
var git = require('git-rev-sync');
var gitVersion = git.long();
var versionDate = new Date();

var $ = require('gulp-load-plugins')({
  pattern: ['gulp-*', 'main-bower-files', 'uglify-save-license', 'del']
});

gulp.task('partials', function () {
  return gulp.src([
    paths.src + '/frontend/**/*.html',
    paths.tmp + '/frontend/**/*.html'
  ])
    .pipe($.minifyHtml({
      empty: true,
      spare: true,
      quotes: true
    }))
    .pipe($.angularTemplatecache('templateCacheHtml.js', {
      module: 'grassberryHigh'
    }))
    .pipe(gulp.dest(paths.tmp + '/partials/'));
});

gulp.task('html', ['inject', 'partials'], function () {
  var partialsInjectFile = gulp.src(paths.tmp + '/partials/templateCacheHtml.js', { read: false });
  var partialsInjectOptions = {
    starttag: '<!-- inject:partials -->',
    ignorePath: paths.tmp + '/partials',
    addRootSlash: false
  };

  var htmlFilter = $.filter('*.html');
  var jsFilter = $.filter('**/*.js');
  var cssFilter = $.filter('**/*.css');
  var assets;

  return gulp.src(paths.tmp + '/serve/*.html')
    .pipe($.inject(partialsInjectFile, partialsInjectOptions))
    .pipe(assets = $.useref.assets())
    .pipe($.rev())
    .pipe(jsFilter)
    .pipe($.replace('GULP_LATEST_UPDATE', versionDate))
    .pipe($.replace('GULP_LATEST_GIT', gitVersion))
    .pipe($.ngAnnotate())
    .pipe($.uglify({preserveComments: $.uglifySaveLicense}))
    .pipe(jsFilter.restore())
    .pipe(cssFilter)
    .pipe($.replace('../../bower_components/bootstrap-sass-official/assets/fonts/bootstrap/', '../fonts/'))
    .pipe($.replace('../bootstrap-sass-official/assets/fonts/bootstrap', '../fonts/'))
    .pipe($.csso())
    .pipe(cssFilter.restore())
    .pipe(assets.restore())
    .pipe($.useref())
    .pipe($.revReplace())
    .pipe(htmlFilter)
    .pipe($.minifyHtml({
      empty: true,
      spare: true,
      quotes: true
    }))
    .pipe(htmlFilter.restore())
    .pipe(gulp.dest(paths.dist + '/'))
    .pipe($.size({ title: paths.dist + '/', showFiles: true }));
});

gulp.task('images', function () {
  return gulp.src([paths.src + '/**/*.{jpg,jpeg,png,svg}', '!'+'/**/*/*-sprite*'])
    .pipe($.rename({dirname: ''}))
    .pipe(gulp.dest(paths.dist + '/assets/images/'));
});

gulp.task('images_tmp', function () {
  return gulp.src(paths.src + '/**/*.{jpg,jpeg,png,svg}')
    .pipe($.rename({dirname: ''}))
    .pipe(gulp.dest(paths.tmp + '/serve/assets/images/'));
});
gulp.task('fonts', function () {
  gulp.src($.mainBowerFiles())
    .pipe($.filter('**/*.{eot,svg,ttf,woff,woff2}'))
    .pipe($.flatten())
    .pipe(gulp.dest(paths.dist + '/fonts/'));

  return gulp.src(paths.src + '/frontend/assets/fonts/**/*.{eot,svg,ttf,woff,woff2}')
    .pipe($.flatten())
    .pipe(gulp.dest(paths.dist + '/fonts/'));
});

gulp.task('fonts_tmp', function () {
  gulp.src($.mainBowerFiles())
    .pipe($.filter('**/*.{eot,svg,ttf,woff,woff2}'))
    .pipe($.flatten())
    .pipe(gulp.dest(paths.tmp + '/serve/fonts/'));

  return gulp.src(paths.src + '/frontend/assets/fonts/**/*.{eot,svg,ttf,woff,woff2}')
    .pipe($.flatten())
    .pipe(gulp.dest(paths.tmp + '/serve/fonts/'));
});

gulp.task('misc', function () {
  gulp.src(paths.src + '/backend/**/*.xml')
    .pipe(gulp.dest(paths.dist + '/'));
  gulp.src(paths.src + '/backend/**/*.template.*')
    .pipe(gulp.dest(paths.dist + '/'));

  var destPy = paths.dist + '/backend/';
  gulp.src(paths.src + '/backend/**/*.py')
    .pipe(gulp.dest(destPy));

  var destShell = paths.dist + '/backend/';
  gulp.src(paths.src + '/backend/**/*.sh')
    .pipe(gulp.dest(destShell));

  return gulp.src(paths.src + '/**/*.ico')
    .pipe(gulp.dest(paths.dist + '/'));
});

gulp.task('misc_tmp', function () {
  gulp.src(paths.src + '/backend/**/*.xml')
    .pipe(gulp.dest(paths.tmp + '/serve/backend'));
  return gulp.src(paths.src + '/backend/**/*.template.*')
    .pipe(gulp.dest(paths.tmp + '/serve/backend'));
});

gulp.task('clean', function (done) {
  $.del([paths.dist + '/', paths.tmp + '/'], done);
});

gulp.task('copy_server', function () {
  var jsFilter = $.filter('**/*.js');
  var serverFilter = $.filter('**/server.js');
  var notServerFilter = $.filter(['**/*', '!**/server.js']);
  return gulp.src([paths.tmp + '/serve/backend/**/*', paths.tmp + '/serve/server.js'])
    .pipe($.replace(urls.development, urls.production))
    // .pipe(jsFilter)
    // .pipe($.uglify({preserveComments: $.uglifySaveLicense}))
    // .pipe(jsFilter.restore())
    .pipe(notServerFilter)
    .pipe(gulp.dest(paths.dist + '/backend/'))
    .pipe(notServerFilter.restore())
    .pipe(serverFilter)
    .pipe(gulp.dest(paths.dist + '/'));

});

gulp.task('build', ['images', 'fonts', 'misc', 'json', 'scripts-backend', 'html', 'createVersionFile'], function(){
  gulp.start('copy_server');
});
