"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'LogService', 'MapService', ($http, $scope, $rootScope, $timeout, LogService, MapService) ->
  $rootScope.overlayIsActive = false
  switchLogs = false
  flow =
    isLogServiceReady: false
    isFirstLogReady: false
    areLogsReady: false
    hasBegun: false
    arePinsDropped: false
    canBegin: false
    urlLogLoadWatch: null
  $scope.log = null
  $scope.otherLog = null

  dropPins = () ->
    console.log 'drop pins'
    dropPin = (log) ->
      return ()->
        MapService.placeMarkerMiniMap(log)

    i = 0
    for logId, log of LogService.logs
      $timeout(dropPin(log),200*i)
      i++
    $timeout(
        () ->
          console.log 'drop pins timeout'
          flow.arePinsDropped = true
          if flow.isFirstLogReady
            console.log 'first log is ready from drop pins'
            $(".main.fade").removeClass("fadeout")
            $(".main.fade").addClass("fadein")
            loadingWatch()
            switchLoading("small corner")
            if $rootScope.urlEntered?
              console.log 'entered url'
              if not LogService.logs[$rootScope.urlEntered].body?
                LogService.getLog($rootScope.urlEntered)
                LogService.getClosestLogs(LogService.logs[$rootScope.urlEntered].key)
                watch = $rootScope.$on('getting-logs', (event, totalLogs) ->
                  console.log 'url watch'
                  if totalLogs is 0
                    console.log 'stop watch'
                    showLog($rootScope.urlEntered, true, null, null, null, true)
                    watch()
                )
              else
                showLog($rootScope.urlEntered, true)
            else
              showLog(LogService.getCurrentLog().id, true, null, null, null, true)
        ,
        200*Object.keys(LogService.logs).length
      )

  $rootScope.$on('map-ready', () ->
    flow.isLogServiceReady = true
    if flow.areLogsReady
      unblockBegin()
  )

  unblockBegin = ()->
    $("#loading").addClass("fadeout")
    $("#start-here").addClass("fadein")
    flow.canBegin = true

  $scope.begin = () ->
    if flow.canBegin
      $("#launch-screen").addClass("fadeout")
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
    console.log '\n'
    switchLogs = not switchLogs
  )

  showLog = (logId, manualSwitch, invert, dontPushState, notChangeMarker, renderBadgeInMain) ->
    console.log 'showlog'
    if logId?
      console.log 'log id'
      log = LogService.logs[logId]
      if invert? and invert
        console.log 'invert'
        console.log 'history change'
        if not switchLogs
          console.log 'not switchlogs -> otherlog'
          $scope.otherLog = log
        else
          console.log 'switchlogs -> log'
          $scope.log = log
        $scope.$apply()
      else
        console.log 'no invert'
        if switchLogs
          console.log 'switchlogs -> otherlog'
          $scope.otherLog = log
        else
          console.log 'not switchlogs -> log'
          $scope.log = log
      if log.profileId?
        console.log 'profileid'
        if renderBadgeInMain? and renderBadgeInMain
          console.log "rendering badge in main"
          renderBadge(log.profileId, '.main')
        else
          console.log "rendering badge in launch"
          renderBadge(log.profileId, '.launch')
      else
        console.log 'no profileid'
        if renderBadgeInMain? and renderBadgeInMain
          $(".main .log-author").html(log.profileName)
        else
          $(".launch .log-author").html(log.profileName)
      if not dontPushState? or not dontPushState
        console.log 'pushstate'
        history.pushState(log.id, log.title, "/log/"+log.id)
      if manualSwitch? and manualSwitch
        console.log 'manual switch'
        switchLogs = not switchLogs
      LogService.current = log.key
      if not notChangeMarker? or not notChangeMarker
        console.log log.id
        MapService.changeLocation(logId)
      console.log 'finish showing log'
    else
      console.log 'no logid'

  $scope.move = (direction) ->
    if LogService.loadingLogs == 0
      LogService.move(direction)
      log = LogService.getCurrentLog()
      console.log log
      console.log 'showing log'
      showLog(log.id, null, null, null, true)
      console.log 'moving'
      move(direction)
      $timeout(()->
        console.log log.id
        MapService.changeLocation(log.id)
      , 500
      )

  $rootScope.$on('switch-marker', (event, logId) ->
    console.log "switching marker"
    $(".main" + " .log-author").css({"opacity": 0})
    if LogService.logs[logId].body?
      console.log "body exists"
      showLog(logId, false, true, false, false, true)
    else
      console.log "fetching body"
      LogService.getLog(logId)
      LogService.getClosestLogs(LogService.logs[logId].key)
      watch = $rootScope.$on('getting-logs', (event, isLoading) ->
        if not isLoading
          showLog(logId, false, true, false, false, true)
          watch()
      )
  )

  loadingWatch = () ->
    if LogService.loadingLogs == 0
      fadeLoading(true)
    else
      fadeLoading(false)
    $rootScope.$on('getting-logs', (event, isLoading) ->
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
      $rootScope.setShowing()

  MapService.init()

  LogService.init().then((logs) ->
    $rootScope.logs = logs
  ,null
  ,(progress) ->
    switch progress
      when 0
        flow.areLogsReady = true
        if flow.isLogServiceReady
          unblockBegin()
      when 1
        console.log 'first log ready'
        flow.isFirstLogReady = true
        if flow.arePinsDropped
          console.log 'pins are dropped from first log ready'
          $(".main.fade").removeClass("fadeout")
          $(".main.fade").addClass("fadein")
          loadingWatch()
          switchLoading("small corner")
          if $rootScope.urlEntered?
            console.log 'entered url'
            if not LogService.logs[$rootScope.urlEntered].body?
              LogService.getLog($rootScope.urlEntered)
              LogService.getClosestLogs(LogService.logs[$rootScope.urlEntered].key)
              watch = $rootScope.$on('getting-logs', (event, isLoading) ->
                console.log 'url watch'
                if not isLoading
                  console.log 'stop url watch'
                  showLog($rootScope.urlEntered, true, null, null, null, true)
                  watch()
              )
            else
              showLog($rootScope.urlEntered, true)
          else
            console.log "no url entered"
            showLog(LogService.getCurrentLog().id, true, null, null, null, true)
        else
          console.log 'pins not dropped yet'
      when 2
        console.log 'other logs ready'
  )

])

ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope', '$timeout', 'User', ($http, $scope, $rootScope, $timeout, User) ->
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

  $rootScope.$on('addLogServiceSelected', () ->
    $scope.$apply ()->
      $scope.addLogServiceSelected = true
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
      angular.element("html").scope().$broadcast('update-load');
    )
    startAddLogService()

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
          google.maps.event.trigger(addLogService, 'resize')
        , 200)
        returnVal = 'loggedIn'
      else
        returnVal = 'login'
        if $rootScope.overlayIsActive
          fadeLoading(true)
    angular.element("html").scope().$broadcast('update-load');
    $scope.display = returnVal

  $scope.canSubmit = () ->
    return $scope.addLogServiceSelected and $scope.selectedFile?

  $scope.activateOverlay = (view) ->
    $rootScope.overlayIsActive = true
    $scope.changeShowing(view)

  $scope.overlayActive = () ->
    return $scope.overlayIsActive

  $scope.upload = () ->
    if not $scope.canSubmit()
      return
    switchLoading("big center")
    payload =
      gdriveId: $scope.selectedFile.id
      lat: addLogServiceMarker.position.lat()
      lng: addLogServiceMarker.position.lng()

    if User.isPlusUser?
      payload.profileId = User.id
    else
      payload.profileName = User.name
    $scope.loadingMessage = "Sharing your story!"
    $scope.loading = true
    $rootScope.setShowing()
    makePublic(payload.gdriveId, (resp) ->
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


  $scope.startLogin = () ->
    if not $rootScope.loggedIn
      $scope.loading = true
      $scope.loadingMessage = "Logging you in"
      $rootScope.setShowing()
])

