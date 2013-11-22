"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->
  Map.initMap()
  switchLogs = true
  $scope.enterfade = ""
  $scope.applyclass = ""

  $scope.$watch( () ->
    return window.loadingDone
  , () ->
    $scope.getClass()
  ) 

  $scope.getClass = () ->
    console.log window.loadingDone
    $scope.applyclass = if window.loadingDone then "fadeout" else ""
    $scope.enterfade = if window.loadingDone then "fadein" else ""

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
          changeLocation($scope.log.id)
          $(".main.fade").removeClass("fadeout")
          window.loadingDone = true
        ,
        200*Object.keys(Map.data.logs).length
      )

  $rootScope.$on('animation-done', () ->
    switchLogs = not switchLogs
  )

  $rootScope.$on('gotFirstLog', () ->
    $scope.log = Map.getCurrentLog()
    $scope.getClass()
    
  )
  $rootScope.$on('map-init', () ->
    $scope.dropPins()
  )


  $scope.getLog = () ->
    $scope.log = Map.getCurrentLog()

  $scope.move = (direction) ->
    if window.loadingDone
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
  $scope.loggedIn = false
  $scope.myfilesa = {"title":"empty"}
  $scope.selectedFile = null
  $scope.addMapSelected = false
  $scope.overlayIsActive = false
  $scope.loadingMessage = ""
  $scope.completeUrl = ""

  callback = (passedScope)=>
    return (event, name, profileId)=>
      passedScope.loggedIn = true
      passedScope.loading = false
      retrieveAllFiles((resp) ->
        passedScope.$apply(() ->
          passedScope.myfiles = resp
        )
      )
      startAddMap()
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
    $scope.$apply ()->
      $scope.addMapSelected = true
  )
  $scope.isSelected = (file) ->
    return file == $scope.selectedFile

  $scope.selectFile = (file) ->
    $scope.selectedFile = file

  $scope.changeShowing = (view) ->
    $rootScope.showing = view

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
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $scope.overlayIsActive = true
    $scope.changeShowing(view)

  $scope.overlayActive = () ->
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
    ).error (data, status, headers, config) ->

  $scope.startLogin = () ->
    if not $scope.loggedIn
      $scope.loading = true
      $rootScope.loadingClass = "bigLoadCenter"
      $rootScope.loadingSize = "large"
      $scope.loadingMessage = "Logging you in"

])

