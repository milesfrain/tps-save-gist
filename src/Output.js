"use strict";

exports.postMessage = function (data) {
  return function () {
    if (window.frames.length >= 0) {
      window.frames[0].postMessage(data, "*");
    } else {
      console.warn("Frame is not available");
    }
    return {};
  }
};