 const path = require('path');

 module.exports = {
  mode: "development",
  devtool: "eval-source-map",
  entry: {
    iface: [ './pdnd.js' ],
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'build'),
  }
 };
