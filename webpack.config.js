const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  mode: 'development',
  entry: {
    'index.js': './dev/index.js',
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
    new webpack.ProvidePlugin({
      ace: require.resolve('ace-builds/src-noconflict/ace.js'),
    }),
  ],
  module: {
    rules: [
      {
        test: require.resolve('ace-builds/src-noconflict/ace.js'),
        loader: 'exports-loader',
        options: {
          type: 'commonjs',
          exports: 'single window.ace'
        }
      }
    ],
  },
  output: {
    filename: '[name]',
    path: path.resolve(__dirname, 'dist'),
  },
};
