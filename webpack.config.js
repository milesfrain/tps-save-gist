const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
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
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      title: 'Ace Demo',
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
  },
};
