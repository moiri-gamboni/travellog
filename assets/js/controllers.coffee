"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', 'Map', ($http, $scope, Map) ->
  #$scope.map = Map
])
