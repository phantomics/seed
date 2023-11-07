 const path = require('path');

 module.exports = {
  mode: "development",
  devtool: "eval-source-map",
  entry: {
    iface: [ './node_modules/codemirror/dist/index.js', './cm-app.js' ],
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'build'),
  }
 };
