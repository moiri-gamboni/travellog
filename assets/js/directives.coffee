"use strict"
drct = angular.module("mainModule.directives", [])

drct.directive("log", () ->
  return {
    restrict: 'E'
    templateUrl: "/static/app/partials/log.html"
  }
)

drct.directive("otherlog", () ->
  return {
    restrict: 'E'
    templateUrl: "/static/app/partials/otherLog.html"
  }
)
