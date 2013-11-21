"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->
  console.log("A")
  Map.initMap()
  $rootScope.$on('map-init', ()->
    console.log("init")

  )
  $scope.$watch(
    -> Map.data.current,
    (current) ->
      $scope.log = Map.getCurrentLog()
  )
  $scope.getLog = () ->
    $scope.log = Map.getCurrentLog()

  $scope.move = (direction) ->
    Map.move(direction)

  $scope.dropPins = () ->
    dropPin = (log) ->
      return ()->
        placeMarkerMiniMap(log)

    for log, i in Object.keys(Map.data.logs)
      $timeout(
        dropPin(log)
        ,
        200*i
      )


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
