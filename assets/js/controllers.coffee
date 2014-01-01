"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$q', '$http', '$scope', '$rootScope', '$timeout', 'LogService', 'MapService', ($q, $http, $scope, $rootScope, $timeout, LogService, MapService) ->
  $rootScope.overlayIsActive = false
  switchLogs = false
  isFirstLogReady = false
  arePinsDropped = false
  canBegin = false
  $scope.log = null
  $scope.otherLog = null

  dropPins = () ->
    deferredPins = []
    promisedPins = []
    i = 0
    dropPin = (i) ->
      return () ->
        MapService.placeMarkerMiniMap(log)
        deferredPins[i].resolve()

    for logId, log of LogService.logs
      deferredPins[i] = $q.defer()
      $timeout(dropPin(i),200*i)
      i++
    for deferred in deferredPins
      promisedPins.push(deferred.promise)
    return $q.all(promisedPins)

  $scope.begin = () ->
    if canBegin
      $("#launch-screen").addClass("fadeout")
      $("#container").removeClass("hide")
      fadeLoading(false)
      switchLoading("big center")
      $timeout(
        ()->
          dropPins().then(
            ()->
              arePinsDropped = true
              if isFirstLogReady
                $(".main.fade").removeClass("fadeout")
                $(".main.fade").addClass("fadein")
                loadingWatch()
                switchLoading("small corner")
                showLog(LogService.getCurrentLog().id, {manualSwitch:true, renderBadgeInMain:true})
          )
        ,500)



  window.switchLoading = (classString) ->
    loading = $("#loading")
    loading.removeClass("small big center corner")
    loading.addClass(classString)

  $rootScope.$on('sliding-animation-done', () ->
    switchLogs = not switchLogs
  )

  #Default options:
  #manualSwitch = false
  #invert = false
  #pushState = true
  #changeMarker = true
  #renderBadgeInMain = false
  showLog = (logId,options) ->
    if not options?
      options = {}
    if not options.manualSwitch?
      options.manualSwitch = false
    if not options.invert?
      options.invert = false
    if not options.pushState?
      options.pushState = true
    if not options.notChangeMarker?
      options.changeMarker = true
    if not options.renderBadgeInMain?
      options.renderBadgeInMain = false

    if logId?
      log = LogService.logs[logId]
      if options.invert
        if not switchLogs
          $scope.otherLog = log
        else
          $scope.log = log
        $scope.$apply()
      else
        if switchLogs
          $scope.otherLog = log
        else
          $scope.log = log
      if log.profileId?
        if options.renderBadgeInMain
          renderBadge(log.profileId, '.main')
        else
          renderBadge(log.profileId, '.launch')
      else
        if options.renderBadgeInMain
          $(".main .log-author").html(log.profileName)
        else
          $(".launch .log-author").html(log.profileName)
      if options.pushState
        history.pushState(log.id, log.title, "/log/"+log.id)
      if options.manualSwitch
        switchLogs = not switchLogs
      LogService.current = log.key
      if options.changeMarker
        MapService.changeLocation(logId)
    else
      console.log 'no logid'

  $scope.move = (direction) ->
    if LogService.logsLoading == 0
      LogService.move(direction)
      log = LogService.getCurrentLog()
      showLog(log.id, {changeMarker:false})
      move(direction)
      $timeout(()->
        MapService.changeLocation(log.id)
      , 500
      )

  $rootScope.$on('switch-marker', (event, logId) ->
    $(".main" + " .log-author").css({"opacity": 0})
    if LogService.logs[logId].body?
      showLog(logId, {invert:true, renderBadgeInMain:true})
    else
      LogService.getLog(logId)
      LogService.getClosestLogs(LogService.logs[logId].key)
      watch = $rootScope.$on('logs-loading', () ->
        if LogService.loadingLogs == 0
          showLog(logId, {invert:true, renderBadgeInMain:true})
          watch()
      )
  )

  loadingWatch = () ->
    f = () ->
      if LogService.loadingLogs == 0
        fadeLoading(true)
      else
        fadeLoading(false)
    f()
    $rootScope.$on('logs-loading', () ->
      f()
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
      showLog(event.state, {invert:true, pushState:false})

  $scope.deactivateOverlay = (view) ->
    $rootScope.overlayIsActive = false

  $scope.changeShowing = (view) ->
    if !$("#loading").hasClass("fadein")
      $rootScope.loadingposition = "big center"
      $rootScope.showing = view
      $rootScope.overlayIsActive = true
      if $rootScope.loggedIn and not $rootScope.filesLoaded
        $rootScope.pullFiles()
      $rootScope.setShowing()

  MapService.init()
  LogService.initLogs().then(
    (logs) ->
      $("#loading").addClass("fadeout")
      $("#start-here").addClass("fadein")
      canBegin = true
      return LogService.initLog($rootScope.urlEntered)
  ).then(
    (log) ->
      isFirstLogReady = true
      if arePinsDropped
        $(".main.fade").removeClass("fadeout")
        $(".main.fade").addClass("fadein")
        loadingWatch()
        switchLoading("small corner")
        showLog(LogService.getCurrentLog().id, {manualSwitch:true, renderBadgeInMain:true})
      return LogService.getClosestLogs(LogService.getCurrentLog().key)
  ).then(
    (data) ->
      return
  )


])

ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope', '$timeout', 'User', 'MapService', ($http, $scope, $rootScope, $timeout, User, MapService) ->
    #if user is signed_in
  #$scope.map = LogService
  $rootScope.showing = 'loading'
  $scope.display = 'loading'
  $rootScope.loggedIn = false
  $scope.myfiles = []
  $scope.numFilesMessage = ""
  $scope.filesLoaded = false
  $scope.selectedFile = null
  $scope.addLogServiceSelected = false
  $scope.loading = false
  $rootScope.filesLoaded = false
  $scope.startedFileLoad = false
  $scope.loadingMessage = ""
  $scope.completeUrl = ""
  $scope.successMessage = ""

  $rootScope.$on('loggedIn', (event, resp) ->
    User = resp
    $rootScope.loggedIn = true
    $scope.loading = true
    $rootScope.setShowing()
    $scope.$apply(() ->
      $scope.loadingMessage = "Loading your drive"
    )
    if $rootScope.overlayIsActive
      $rootScope.pullFiles()
  )
  $rootScope.$on("partialFilesLoaded", (event, newFiles) ->
    $scope.$apply ()->
      $scope.numFilesMessage = newFiles.length + " Files Loaded"
      if not $scope.startedFileLoad
        $scope.loading = false
        switchLoading("small top")
      $scope.startedFileLoad = true
      $scope.myfiles = newFiles
      $rootScope.setShowing()
  )

  $scope.submitAgain = () ->
    $scope.complete = false
    $rootScope.setShowing()

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
      angular.element("html").scope().$broadcast('update-load')
    )
    MapService.startAddMap()

  $rootScope.setShowing = () ->
    returnVal = ""
    if $rootScope.showing == "help"
      if $rootScope.overlayIsActive
          fadeLoading(true)
          returnVal = $rootScope.showing
    else if $rootScope.showing == "addFile"
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
          google.maps.event.trigger(MapService.addMap, 'resize')
        , 200)
        returnVal = 'loggedIn'
      else
        returnVal = 'login'
        if $rootScope.overlayIsActive
          fadeLoading(true)
    angular.element("html").scope().$broadcast('update-load');
    $scope.display = returnVal

  $scope.canSubmit = () ->
    return MapService.addMapMarker and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $rootScope.overlayIsActive = true
    $scope.changeShowing(view)

  $scope.overlayActive = () ->
    return $scope.overlayIsActive

  $scope.upload = () ->
    if not $scope.canSubmit()
      $(".white.small").css({color: "red"})
      $timeout(() ->
        $(".white.small").css("")
      , 2000)
      return
    switchLoading("big center")
    payload =
      gdriveId: $scope.selectedFile.id
      lat: MapService.addMapMarker.position.lat()
      lng: MapService.addMapMarker.position.lng()

    if User.isPlusUser?
      payload.profileId = User.id
    else
      payload.profileName = User.name

    $scope.loadingMessage = "Sharing your story!"
    $scope.loading = true
    $rootScope.setShowing()
    makePublic(payload.gdriveId, (resp) ->
      location = new google.maps.LatLng(payload.lat, payload.lng)
      MapService.reverseGeocode(location, (formatted_address, countryName) ->
        payload.country = countryName
        MapService.geocode(countryName, (location) =>
          payload.countryLat = location.lat()
          payload.countryLng = location.lng()
          addToTravellog(payload.gdriveId, (resp) ->
            $http(
              method: "POST"
              url: "/logs"
              data: payload
            ).success((data, status, headers, config) ->
             $scope.loading = false
             $scope.complete = true
             $rootScope.setShowing()
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
      )
    )


  $scope.startLogin = () ->
    if not $rootScope.loggedIn
      $scope.loading = true
      $scope.loadingMessage = "Logging you in"
      $rootScope.setShowing()
])

