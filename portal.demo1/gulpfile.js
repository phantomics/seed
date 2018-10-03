(function () {
    var gulp = require('gulp');
    var webpack = require('webpack');
    var gulpWebpack = require('gulp-webpack');
    var webpackConfig = { context : '/home/sloane/src/lisp/seed/portal.demo1/',
                          entry : { 'main' : './src.js' },
                          resolve : { extensions : ['', '.js', '.json'] },
                          node : { fs : 'empty', child_process : 'empty' },
                          output : { filename : './[name].js' },
                          module : { loaders : [{ test : /.json$/, loaders : ['json-loader'] }] }
                        };
    return gulp.task('dev', function () {
        return gulp.src('/home/sloane/src/lisp/seed/portal.demo1/src.js').pipe(gulpWebpack(webpackConfig)).pipe(gulp.dest('/home/sloane/src/lisp/seed/portal.demo1/'));
    });
})();