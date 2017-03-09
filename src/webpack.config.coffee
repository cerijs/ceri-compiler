path = require "path"
webpack = require "webpack"
UglifyJSPlugin = require "uglifyjs-webpack-plugin"
module.exports = {
  output:
    publicPath: "/"
    filename: "bundle.js"
  module:
    rules: [
      { test: /\.coffee$/, use: "coffee-loader"}
      {
        test: /\.(js|coffee)$/
        use: "ceri-loader"
        enforce: "post"
        exclude: /node_modules/
      }

    ]
  plugins: [
    new webpack.DefinePlugin "process.env.NODE_ENV": JSON.stringify("production")
    new UglifyJSPlugin compress: warnings: false
  ]
}
