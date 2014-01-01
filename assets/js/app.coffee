"use strict"

module = angular.module("mainModule", ["ngSanitize", "mainModule.services", "mainModule.controllers", "mainModule.directives"])
module.run(($rootScope)->
  logId = window.location.pathname.slice(5)
  if logId != ""
    $rootScope.urlEntered = logId
)

window.getSrv = (name, element) ->
  element = element || '*[ng-app]'
  return angular.element(element).injector().get(name)
