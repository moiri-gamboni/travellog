// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var drct;

  drct = angular.module("mainModule.directives", []);

  drct.directive("log", function() {
    return {
      restrict: 'E',
      templateUrl: "/static/app/partials/log.html"
    };
  });

  drct.directive("otherlog", function() {
    return {
      restrict: 'E',
      templateUrl: "/static/app/partials/otherLog.html"
    };
  });

  drct.directive("loading", function() {
    return {
      restrict: 'E',
      templateUrl: "/static/app/partials/loading.html"
    };
  });

}).call(this);
