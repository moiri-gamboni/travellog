"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->
  Map.initMap()
  switchLogs = true
  $scope.enterfade = ""
  $scope.applyclass = ""
  $rootScope.loadingposition = ""


  $rootScope.$on('history-change', (logId) ->
    console.log("history change")
    console.log(logId)
    Map.data.current = Map.data.logs[logId].key
    if switchLogs
        $scope.otherLog = Map.data.logs[logId]
      else
        $scope.log = Map.data.logs[logId]
  )
  
  $scope.$watch( () ->
    return $rootScope.loadingposition
  , () ->
    $scope.getClass()
  ) 

  $scope.enter = () ->
    $rootScope.loadingposition = "center big"

  $scope.popout = () ->
    $rootScope.loadingposition = "corner small"

  $scope.getClass = () ->
    $scope.applyclass = (if window.loadingDone then "fadeout" else "") + " " + $rootScope.loadingposition
    console.log $scope.applyclass
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
          $rootScope.loadingposition = "corner small"
          $scope.getClass()
          window.loadingDone = true
        ,
        200*Object.keys(Map.data.logs).length
      )

  $rootScope.$on('update-load', () ->
    $scope.getClass()
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
  $rootScope.$on('map-ready', () ->
    $scope.$watch( () ->
      return window.loadingDone
    , () ->
      $scope.getClass()
    ) 
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

ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope', 'User', ($http, $scope, $rootScope, User) ->
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
  $scope.successMessage = ""

  callback = (passedScope)=>
    return (event, resp)=>
      User = resp
      passedScope.loggedIn = true
      passedScope.loading = true
      passedScope.loadingMessage = "Loading your drive(this could take a while)"
      retrieveAllFiles((resp) ->
        passedScope.$apply(() ->
          passedScope.myfiles = resp
        )
        console.log "finishing up"
        $scope.$apply(() ->
          $scope.loading = false
        )
        angular.element("html").scope().$broadcast('update-load');
      )
      startAddMap()
  $rootScope.$on('loggedIn', callback($scope))
  $rootScope.$on('addMapSelected', () ->
    $scope.$apply ()->
      $scope.addMapSelected = true
  )
  $scope.submitAgain = () ->
    $scope.complete = false

  $scope.isSelected = (file) ->
    return file == $scope.selectedFile

  $scope.selectFile = (file) ->
    $scope.selectedFile = file

  $scope.changeShowing = (view) ->
    if window.loadingDone
      $rootScope.loadingposition = "big center"
      $rootScope.showing = view

  $scope.$watch( () ->
    return $scope.loading
  , () ->
    $scope.getShowing()
  ) 

  $scope.getShowing = () ->
    if $rootScope.showing == "help"
      return $rootScope.showing
    returnVal = ""
    if $rootScope.showing == "addFile"
      if $scope.loading
        window.loadingDone = false
        returnVal = 'loading'
      else if $scope.complete
        window.loadingDone = true
        returnVal = 'complete'
      else if $scope.loggedIn
        window.loadingDone = true
        setTimeout( ()->
          google.maps.event.trigger(addMap, 'resize')
        , 200)
        returnVal = 'loggedIn'
      else
        returnVal = 'login'
    angular.element("html").scope().$broadcast('update-load');
    console.log returnVal
    return returnVal

  $scope.canSubmit = () ->
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $scope.overlayIsActive = true
    $rootScope.loadingposition = "big center"
    console.log($rootScope.loadingposition)
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

    if User.isPlusUser?
      payload.profileId = User.id
    else
      payload.profileName = User.name
    $scope.loadingMessage = "Sharing your story!"
    $scope.loading = true
    makePublic(payload.gdriveId, (resp) ->
      console.log "made Public"
      console.log resp
      addToTravellog(payload.gdriveId, (resp) ->
        console.log "shared to travellog"
        console.log resp
        $http(
          method: "POST"
          url: "/logs"
          data: payload
        ).success((data, status, headers, config) ->
         $scope.loading = false
         $scope.complete = true
         if data.status == 200
            $scope.completeUrl = "http://www.travellog.io/log/" + $scope.selectedFile.id
            $scope.successMessage = "Congratulations, your travel log has been uploaded and is available at:"
          else
            $scope.completeUrl = ""
            $scope.successMessage = data.error
        ).error (data, status, headers, config) ->
      )
    )




  $scope.startLogin = () ->
    if not $scope.loggedIn
      $scope.loading = true
      $scope.loadingMessage = "Logging you in"

])

