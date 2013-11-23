"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->

  $rootScope.overlayIsActive = false
  switchLogs = false
  flow =
    isMapReady: false
    isFirstLogReady: false
    areLogsReady: false
    hasBegun: false
    arePinsDropped: false
    canBegin: false
    urlLogLoadWatch: null

  dropPins = () ->
    dropPin = (log) ->
      return ()->
        placeMarkerMiniMap(log)

    i = 0
    for logId, log of Map.data.logs
      $timeout(dropPin(log),200*i)
      i++
    $timeout(
        () ->
          flow.arePinsDropped = true
          if flow.isFirstLogReady
            $(".main.fade").removeClass("fadeout")
            $(".main.fade").addClass("fadein")
            loadingWatch()
            switchLoading("small corner")
            if $rootScope.urlEntered?
              Map.getLog($rootScope.urlEntered)
              flow.urlLogLoadWatch = $rootScope.$on('is-loading-log', (event, isLoading) ->
                if not isLoading
                  showLog($rootScope.urlEntered, true)
                  flow.urlLogLoadWatch()
              )
            else
              showLog(Map.getCurrentLog().id, true)
        ,
        200*Object.keys(Map.data.logs).length
      )

  $rootScope.$on('map-ready', () ->
    flow.isMapReady = true
    if flow.areLogsReady
      unblockBegin()
  )

  $rootScope.$on('logs-ready', () ->
    flow.areLogsReady = true
    if flow.isMapReady
      unblockBegin()
  )

  $rootScope.$on('first-log-ready', () ->
    flow.isFirstLogReady = true
    if flow.arePinsDropped
      $(".main.fade").removeClass("fadeout")
      $(".main.fade").addClass("fadein")
      loadingWatch()
      switchLoading("small corner")
      if $rootScope.urlEntered?
        Map.getLog($rootScope.urlEntered)
        flow.urlLogLoadWatch = $rootScope.$on('is-loading-log', (event, isLoading) ->
          if not isLoading
            showLog($rootScope.urlEntered, true)
            flow.urlLogLoadWatch()
        )
      else
        showLog(Map.getCurrentLog().id, true)
  )

  unblockBegin = ()->
    $("#loading").addClass("fadeout")
    $("#start-here").addClass("fadein")
    flow.canBegin = true

  $scope.begin = () ->
    if flow.canBegin
      $("#launch-screen, .background").addClass("hide")
      $("#container").removeClass("hide")
      fadeLoading(false)
      switchLoading("big center")
      flow.hasBegun = true
      $timeout(()->
        dropPins()
      , 500)

  window.switchLoading = (classString) ->
    loading = $("#loading")
    loading.removeClass("small big center corner")
    loading.addClass(classString)


  $rootScope.$on('sliding-animation-done', () ->
    console.log 'animation done'
    switchLogs = not switchLogs
  )

  showLog = (logId, manualSwitch, invert, dontPushState) ->
    if logId?
      log = Map.data.logs[logId]
      if invert? and invert
        if historyChange? and historyChange
          if not switchLogs
            $scope.otherLog = log
          else
            $scope.log = log
        if log.profileId?
          if not switchLogs
            renderBadge(log.profileId, '.launch')
          else
            renderBadge(log.profileId, '.main')
        else
          if not switchLogs
            $(".launch .log-author").html(log.profileName)
          else
            $(".main .log-author").html(log.profileName)
        $scope.$apply()
      else
        if switchLogs
          $scope.otherLog = log
        else
          $scope.log = log
        if log.profileId?
          if switchLogs
            renderBadge(log.profileId, '.launch')
          else
            renderBadge(log.profileId, '.main')
        else
          if switchLogs
            $(".launch .log-author").html(log.profileName)
          else
            $(".main .log-author").html(log.profileName)
      if not dontPushState? or not dontPushState
        history.pushState(log.id, log.title, "/log/"+log.id)
      if manualSwitch? and manualSwitch
        switchLogs = not switchLogs
      Map.data.current = log.key
      changeLocation(logId)

  $scope.move = (direction) ->
    if Map.data.loadingLogs == 0
      log = Map.move(direction)
      showLog(log.id)
      move(direction)

  $rootScope.$on('switch-marker', (event, logId) ->
    if Map.data.logs[logId].body?
      showLog(logId, false, true)
    else
      Map.getLog(logId)
      watch = $rootScope.$on('is-loading-log', (event, isLoading) ->
        if not isLoading
          showLog(logId, false, true)
          watch()
      )
  )

  loadingWatch = () ->
    if Map.data.loadingLogs == 0
      fadeLoading(true)
    else
      fadeLoading(false)
    $rootScope.$on('is-loading-log', (event, isLoading) ->
      if isLoading
        fadeLoading(false)
      else
        fadeLoading(true)
    )

  window.fadeLoading = (fadeOut) ->
    if fadeOut
      $("#loading").addClass("fadeout")
      $("#loading").removeClass("fadein")
    else
      $("#loading").removeClass("fadeout")
      $("#loading").addClass("fadein")

  window.onpopstate = (event) ->
    if event.state?
      showLog(event.state, false, true, true)


  $scope.deactivateOverlay = (view) ->
    $rootScope.overlayIsActive = false

  $scope.changeShowing = (view) ->
    if !$("#loading").hasClass("fadein")
      $rootScope.loadingposition = "big center"
      $rootScope.showing = view
      $rootScope.overlayIsActive = true
      if $rootScope.loggedIn and not $rootScope.filesLoaded
        $rootScope.pullFiles()


  Map.initMap()


])

ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope', 'User', ($http, $scope, $rootScope, User) ->
    #if user is signed_in
  #$scope.map = Map
  $rootScope.showing = 'loading'
  $rootScope.loggedIn = false
  $scope.myfiles = []
  $scope.numFilesMessage = ""
  $scope.filesLoaded = false
  $scope.selectedFile = null
  $scope.addMapSelected = false
  $scope.loading = false
  $rootScope.filesLoaded = false
  $scope.loadingMessage = ""
  $scope.completeUrl = ""
  $scope.successMessage = ""

  $rootScope.$on('loggedIn', (event, resp) ->
    User = resp
    $rootScope.$apply ()->
      $rootScope.loggedIn = true
    $scope.loading = true
    $scope.$apply(() ->
      $scope.loadingMessage = "Loading your drive (this could take a while)"
    )
    if $rootScope.overlayIsActive
      $rootScope.pullFiles()
  )
  $rootScope.$on("partialFilesLoaded", (event, newFiles) ->
    $scope.$apply ()->
      $scope.numFilesMessage = "Still loading...<br />" + newFiles.length + " Files Loaded"
      $scope.loading = false
      switchLoading("small top")
      $scope.myfiles = newFiles
  )

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

  $rootScope.pullFiles = () ->
    $rootScope.filesLoaded = true
    retrieveAllFiles((resp) ->
      $scope.$apply(() ->
        $scope.filesLoaded = true
        $scope.numFilesMessage = "All " + $scope.myfiles.length + " files loaded"
        fadeLoading(true)
        $timeout(() ->
          switchLoading("center big")
        , 500
        )
      )
      angular.element("html").scope().$broadcast('update-load');
    )
    startAddMap()

  $scope.$watch( () ->
    return $scope.loading
  , () ->
    $scope.getShowing()
  )

  $scope.getShowing = () ->
    if $rootScope.showing == "help"
      if $rootScope.overlayIsActive
          fadeLoading(true)
      return $rootScope.showing
    returnVal = ""
    if $rootScope.showing == "addFile"
      if $scope.loading
        if $rootScope.overlayIsActive
          fadeLoading(false)
        returnVal = 'loading'
      else if $scope.complete
        if $rootScope.overlayIsActive
          fadeLoading(true)
        returnVal = 'complete'
      else if $rootScope.loggedIn
        if $rootScope.overlayIsActive and not $scope.filesLoaded
          fadeLoading(false)
        else if $rootScope.overlayIsActive and $scope.filesLoaded
          fadeLoading(true)
        setTimeout( ()->
          google.maps.event.trigger(addMap, 'resize')
        , 200)
        returnVal = 'loggedIn'
      else
        returnVal = 'login'
        if $rootScope.overlayIsActive
          fadeLoading(true)
    angular.element("html").scope().$broadcast('update-load');
    return returnVal

  $scope.canSubmit = () ->
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $rootScope.overlayIsActive = true
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
          return
      )
    )


  $scope.startLogin = () ->
    if not $rootScope.loggedIn
      $scope.loading = true
      $scope.loadingMessage = "Logging you in"
])

