var gulp = require('gulp');
var paths = gulp.paths;
var $ = require('gulp-load-plugins')();

gulp.task('pack', ['build'], function(){
  return gulp.src(paths.dist, {read: false})
  .pipe($.shell([
    'tar -zcvf "$(date +%Y-%m-%dT%H_%M_%S%z)".tar.gz ./dist package.json bower.json && open ./'
  ]))

})