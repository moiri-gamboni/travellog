"use strict"

module = angular.module("mainModule", ["ngSanitize", "mainModule.services", "mainModule.controllers", "mainModule.directives"])
module.run(($rootScope)->
  logId = window.location.pathname.slice(5)
  if logId != ""
    $rootScope.urlEntered = logId

  $rootScope.$watch(()->
    return angular.element('body').scope()
  , (oldScope, newScope) ->
    console.log oldScope
    console.log newScope
    console.log
  )
)
