 const path = require('path');

 module.exports = {
  mode: "development",
  devtool: "eval-source-map",
  entry: {
    codemirror: './node_modules/codemirror/dist/index.js',
    cmApp: './static/cm-app.js',
    // alpinejs: './node_modules/alpinejs/dist/cdn.js',
    // htmx: './node_modules/htmx.org/dist/htmx.js',
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'static'),
  },
  /*plugins: [
    new MergeIntoSingleFilePlugin({
      "bundle.js": [
        path.resolve(__dirname, './node_modules/codemirror/dist/index.js'),
        path.resolve(__dirname, './node_modules/alpinejs/dist/cdn.js'),
        path.resolve(__dirname, './node_modules/htmx.org/dist/htmx.js')
      ] //,
      //"bundle.css": [
      //  path.resolve(__dirname, 'src/css/main.css'),
      //  path.resolve(__dirname, 'src/css/local.css')
      //]
   })
  ]*/
 };
