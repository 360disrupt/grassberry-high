'use strict';

var gulp = require('gulp');
var paths = gulp.paths;

var licenseFind = require('gulp-license-finder');

gulp.task('licenses', function() {
    return licenseFind('outputfile.txt')
        .pipe(gulp.dest('./audit'))
});