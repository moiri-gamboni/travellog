"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->

  switchLogs = false
  flow =
    isMapReady: false
    isFirstLogReady: false
    areLogsReady: false
    hasBegun: false
    arePinsDropped: false
    canBegin: false

  dropPins = () ->
    dropPin = (log) ->
      return ()->
        placeMarkerMiniMap(log)

    i = 0
    for logId, log of Map.data.logs
      console.log i
      $timeout(dropPin(log),200*i)
      i++
    $timeout(
        () ->
          flow.arePinsDropped = true
          console.log 'pins are dropped'
          if flow.isFirstLogReady
            $(".main.fade").removeClass("fadeout")
            switchLoading("small corner")
            showLog()
        ,
        200*Object.keys(Map.data.logs).length
      )

  $rootScope.$on('map-ready', () ->
    console.log 'map-ready'
    flow.isMapReady = true
    if flow.areLogsReady
      unblockBegin()
  )

  $rootScope.$on('logs-ready', () ->
    console.log 'logs-ready'
    flow.areLogsReady = true
    if flow.isMapReady
      unblockBegin()
  )

  $rootScope.$on('first-log-ready', () ->
    console.log 'first-log-ready'
    flow.isFirstLogReady = true
    if flow.arePinsDropped
      $(".main.fade").removeClass("fadeout")
      switchLoading("small corner")
      showLog()
  )

  unblockBegin = ()->
    console.log 'unlock begin'
    $("#loading").addClass("fadeout")
    $("#start-here").addClass("fadein")
    flow.canBegin = true
    $rootScope.$on('unlock-animation-done', () ->
      console.log 'unlock-animation-done'
      switchLoading("big center")
    )

  $scope.begin = () ->
    if flow.canBegin
      $("#launch-screen, .background").addClass("hide")
      $("#container").removeClass("hide")
      flow.hasBegun = true
      $timeout(()->
        dropPins()
      , 500)

  switchLoading = (classString) ->
    console.log 'switchLoading'+ " " + classString
    $("#loading").removeClass("small big center corner")
    $("#loading").addClass(classString)


  $rootScope.$on('sliding-animation-done', () ->
    switchLogs = not switchLogs
  )

  showLog = (logId) ->
    if logId?

    else
      if switchLogs
        $scope.otherLog = Map.getCurrentLog()
        changeLocation($scope.otherLog.id)
      else
        $scope.log = Map.getCurrentLog()
        changeLocation($scope.log.id)

  $scope.move = (direction) ->
    if window.loadingDone
      if switchLogs
        $scope.otherLog = Map.move(direction)
        changeLocation($scope.otherLog.id)
      else
        $scope.log = Map.move(direction)
        changeLocation($scope.log.id)


  Map.initMap()


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
      console.log "finishing login"
      User = resp
      console.log User
      passedScope.$apply ()->
        passedScope.loggedIn = true
      passedScope.loading = true
      passedScope.loadingMessage = "Loading your drive(this could take a while)"
      retrieveAllFiles((resp) ->
        passedScope.$apply(() ->
          passedScope.myfiles = resp
        )
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

    return returnVal

  $scope.canSubmit = () ->
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $scope.overlayIsActive = true
    $rootScope.loadingposition = "big center"

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


      addToTravellog(payload.gdriveId, (resp) ->


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

