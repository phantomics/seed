(function () {
    var gulp = require('gulp');
    var webpack = require('webpack');
    var gulpWebpack = require('webpack-stream');
    var webpackConfig = { context : '/home/sloane/src/lisp/seed2/portals/portal.demo1/',
                          entry : { 'lib' : './src.js' },
                          resolve : { extensions : ['.js', '.json'] },
                          node : { fs : 'empty', child_process : 'empty' },
                          output : { filename : './[name].js' },
                          module : { rules : [{ test : /.json$/, loaders : ['json-loader'] }, { test : /.js$/,
                                                                                                loader : 'babel-loader',
                                                                                                options : { presets : ['@babel/preset-env'] }
                                                                                              }] }
                        };
    gulp.task('dev', function () {
        __PS_MV_REG = [];
        return gulp.src('/home/sloane/src/lisp/seed2/portals/portal.demo1/src.js').pipe(gulpWebpack(webpackConfig)).pipe(gulp.dest('/home/sloane/src/lisp/seed2/portals/portal.demo1/'));
    });
    __PS_MV_REG = [];
    return true;
})();