const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  mode: 'development',
  entry: {
    "index.js": [
      require.resolve("ace-builds/src-noconflict/ace.js"),
     "./dev/tailwind.css",
     "./dev/index.js",
    ],
  },
  devtool: false,
  devServer: {
    contentBase: './dist',
    // Allow deeper routes to fallback to index.html
    // Note that publicPath also needs to be set for this to work.
    historyApiFallback: true,
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      title: 'Ace Demo',
    }),
    new CopyPlugin({
      patterns: [
        {from: 'dev/frame-load.js', to: 'frame-load.js'},
        {from: 'dev/img', to: 'img'},
      ],
    }),
  ],
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader',
        ],
      },
    ],
  },
  output: {
    filename: '[name]',
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/',
  },
};