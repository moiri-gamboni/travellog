"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->
  Map.initMap()
  switchLogs = true

  $scope.dropPins = () ->
    dropPin = (log) ->
      return ()->
        placeMarkerMiniMap(log)

    i = 0
    for logId, log of Map.data.logs
      $timeout(
        dropPin(log)
        ,
        200*i
      )
      i++
    $timeout(
        () ->
          console.log($scope.log.id)
          changeLocation($scope.log.id)
        ,
        2800
      )

  $rootScope.$on('animation-done', () ->
    console.log("firing")
    switchLogs = not switchLogs
  )

  $rootScope.$on('gotFirstLog', () ->
    $scope.log = Map.getCurrentLog()
    $scope.dropPins()
  )

  $scope.getLog = () ->
    $scope.log = Map.getCurrentLog()

  $scope.move = (direction) ->
    if switchLogs
      $scope.otherLog = Map.move(direction)
      changeLocation($scope.otherLog.id)
    else
      $scope.log = Map.move(direction)
      changeLocation($scope.log.id)





])
ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope', 'User', ($http, $scope, $rootScope, User) ->
  $scope.myfiles = {"title":"empty"}
  $scope.selectedFile = null
  $scope.addMapSelected = false

  $rootScope.$on('loggedIn',
    (event, resp)=>
      User = resp
      $scope.$apply(() ->
        $scope.loggedIn = true
      )
      retrieveAllFiles((resp) ->
        $scope.$apply(() ->
          $scope.myfiles = resp
        )
      )
  )

  $rootScope.$on('addMapSelected', () ->
    $scope.$apply ()->
      $scope.addMapSelected = true
  )
  $scope.isSelected = (file) ->
    return file == $scope.selectedFile

  $scope.selectFile = (file) ->
    console.log(User)
    $scope.selectedFile = file

  $scope.canSubmit = () ->
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.upload = () ->
    return
])
