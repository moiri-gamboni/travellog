"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->
  Map.initMap()
  switchLogs = true
  $rootScope.loadingClass = ""
  $rootScope.loadingSize = ""
  $scope.loadingClass = () ->
    classString = $rootScope.loadingClass
    loadSize = $rootScope.loadingSize
    return classString + " " + loadSize
 
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

ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope',($http, $scope, $rootScope) ->
    #if user is signed_in
  #$scope.map = Map
  $rootScope.showing = 'loading'
  console.log('going false')
  $scope.loggedIn = false
  console.log($scope)
  $scope.myfiles = {"title":"empty"}
  $scope.selectedFile = null
  $scope.addMapSelected = false
  $scope.overlayIsActive = false
  console.log $scope.myfiles
  $scope.loadingMessage = ""
  $scope.completeUrl = ""

  callback = (passedScope)=>
    return (event, name, profileId)=>
      console.log "you've been logged in"
      passedScope.loggedIn = true
      passedScope.loading = false
      retrieveAllFiles((resp) ->
        passedScope.$apply(() ->
          passedScope.myfiles = resp
        )
      )
      startAddMap()
      console.log(passedScope.showing)
      if profileId
        passedScope.hasGoogle = true
        $scope.profileId = profileId
      else
        passedScope.hasGoogle = false
        $scope.name = name
  $rootScope.$on('loggedIn', callback($scope))

  callback2 = (passedScope) =>
    return 

  $rootScope.$on('addMapSelected', () ->
    console.log("working away to make mapSelected True")
    $scope.$apply ()->
      $scope.addMapSelected = true
  ) 
  $scope.isSelected = (file) -> 
    return file == $scope.selectedFile
  
  $scope.selectFile = (file) ->
    console.log("selecting file!")
    $scope.selectedFile = file

  $scope.changeShowing = (view) ->
    console.log(view)
    $rootScope.showing = view
    console.log $rootScope.showing

  $scope.getShowing = () ->
    if $rootScope.showing == "help"
      return $rootScope.showing
    if $rootScope.showing == "addFile"
      if $scope.loading
        return 'loading'
      else if $scope.complete
        return 'complete'
      else if $scope.loggedIn
        setTimeout( ()->
          google.maps.event.trigger(addMap, 'resize')
        , 200)
        return 'loggedIn'
      else
        return 'login'

  $scope.canSubmit = () ->
    console.log("checking submit" + $scope.addMapSelected + $scope.selectedFile?)
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $scope.overlayIsActive = true
    $scope.changeShowing(view)

  $scope.overlayActive = () ->
    console.log("activate overlay")
    return $scope.overlayIsActive

  $scope.upload = () ->
    if not $scope.canSubmit()
      return
    payload = 
      gdriveId: $scope.selectedFile.id
      lat: addMapMarker.position.lat()
      lng: addMapMarker.position.lng()

    if $scope.hasGoogle
      payload.profileId = $scope.profileId
    else
      payload.profileName = $scope.name
    $scope.loadingMessage = "Sending your message up!"
    $scope.loading = true
    $rootScope.loadingClass = "bigLoadCenter"
    $rootScope.loadingSize = "large"
    $http(
      method: "POST"
      url: "/logs"
      data: payload
    ).success((data, status, headers, config) ->
      if data.status == 200
        $scope.loading = false
        $scope.complete = true
        $scope.completeUrl = "http://www.travellog.io/log/" + $scope.selectedFile.id
      else
        console.log "no idea what happened"
    ).error (data, status, headers, config) ->

  $scope.startLogin = () ->
    if not $scope.loggedIn
      $scope.loading = true
      $rootScope.loadingClass = "bigLoadCenter"
      $rootScope.loadingSize = "large"
      $scope.loadingMessage = "Logging you in"

])

