'use strict';

var gulp = require('gulp');

var paths = gulp.paths;

var $ = require('gulp-load-plugins')();

gulp.task('styles', function () {

  var sassOptions = {
    style: 'expanded'
  };

//Inject first all base settings
  var preInjectFiles = gulp.src([
    paths.src + '/frontend/_config/**/_load_order.scss',
    '!' + paths.src + '/frontend/index.scss',
    '!' + paths.src + '/frontend/vendor.scss'
  ], { read: false });

  var preInjectOptions = {
    transform: function(filePath) {
      filePath = filePath.replace(paths.src + '/frontend/', '');
      filePath = filePath.replace(paths.src + '/components/', '../components/');
      return '@import \'' + filePath + '\';';
    },
    starttag: '// base',
    endtag: '// endbase',
    addRootSlash: false
  };

//Then add other files, exclude firt injected files
  var injectFiles = gulp.src([
    paths.src + '/frontend/**/*.scss',
    '!' + paths.src + '/frontend/_config/**/*.scss',
    '!' + paths.src + '/frontend/index.scss',
    '!' + paths.src + '/frontend/vendor.scss'
  ], { read: false });

  var injectOptions = {
    transform: function(filePath) {
      filePath = filePath.replace(paths.src + '/frontend/', '');
      filePath = filePath.replace(paths.src + '/components/', '../components/');
      return '@import \'' + filePath + '\';';
    },
    starttag: '// injector',
    endtag: '// endinjector',
    addRootSlash: false
  };

  var indexFilter = $.filter('index.scss');

  return gulp.src([
    paths.src + '/frontend/index.scss',
    paths.src + '/frontend/vendor.scss'
  ])
    .pipe(indexFilter)
    .pipe($.inject(preInjectFiles, preInjectOptions))
    .pipe($.inject(injectFiles, injectOptions))
    .pipe(indexFilter.restore())
    .pipe($.sass(sassOptions))

  .pipe($.autoprefixer())
    .on('error', function handleError(err) {
      console.error(err.toString());
      this.emit('end');
    })
    .pipe(gulp.dest(paths.tmp + '/serve/frontend/'));
});
