"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$rootScope', '$scope', 'Map', ($http, $scope, $rootScope, Map) ->
  #$scope.map = Map
  $rootScope.$on('handle-client-load', (event, apiKey)->
    console.log(apiKey)
  )
])
