(function () {
    var gulp = require('gulp');
    var concat = require('gulp-concat');
    return gulp.task('dev', function () {
        return gulp.src(['/Users/owner/Documents/src/seed/seed.foreign.browser-spec.style.base/node_modules/bootstrap/dist/css/bootstrap.min.css', '/Users/owner/Documents/src/seed/seed.foreign.browser-spec.style.base/node_modules/react-select/dist/react-select.css', '/Users/owner/Documents/src/seed/seed.foreign.browser-spec.style.base/node_modules/codemirror/lib/codemirror.css', '/Users/owner/Documents/src/seed/seed.foreign.browser-spec.style.base/node_modules/codemirror/theme/solarized.css']).pipe(concat('main.css')).pipe(gulp.dest('/Users/owner/Documents/src/seed/portal.demo1/'));
    });
})();