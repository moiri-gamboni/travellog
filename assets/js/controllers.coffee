"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', '$timeout', 'Map', ($http, $scope, $rootScope, $timeout, Map) ->
  console.log 'mainctrl'
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
  $scope.log = null
  $scope.otherLog = null

  console.log 'var init'


  dropPins = () ->
    console.log 'drop pins'
    dropPin = (log) ->
      return ()->
        placeMarkerMiniMap(log)

    i = 0
    for logId, log of Map.data.logs
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
              if not Map.data.logs[$rootScope.urlEntered].body?
                Map.getLog($rootScope.urlEntered)
                watch = $rootScope.$on('is-loading-log', (event, isLoading) ->
                  console.log 'url watch'
                  if not isLoading
                    console.log 'stop watch'
                    showLog($rootScope.urlEntered, true)
                    watch()
                )
              else
                showLog($rootScope.urlEntered, true)
            else
              showLog(Map.getCurrentLog().id, true)
        ,
        200*Object.keys(Map.data.logs).length
      )

  console.log 'drop pins defined'

  $rootScope.$on('map-ready', () ->
    flow.isMapReady = true
    if flow.areLogsReady
      unblockBegin()
  )

  console.log 'map ready defined'

  $rootScope.$on('logs-ready', () ->
    flow.areLogsReady = true
    if flow.isMapReady
      unblockBegin()
  )

  console.log 'logs ready defined'

  $rootScope.$on('first-log-ready', () ->
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
        if not Map.data.logs[$rootScope.urlEntered].body?
          Map.getLog($rootScope.urlEntered)
          watch = $rootScope.$on('is-loading-log', (event, isLoading) ->
            console.log 'url watch'
            if not isLoading
              console.log 'stop url watch'
              showLog($rootScope.urlEntered, true)
              watch()
          )
        else
          showLog($rootScope.urlEntered, true)
      else
        showLog(Map.getCurrentLog().id, true)
    else
      console.log 'pins not dropped yet'
  )

  console.log 'first log ready defined'

  unblockBegin = ()->
    $("#loading").addClass("fadeout")
    $("#start-here").addClass("fadein")
    flow.canBegin = true

  console.log 'unlock begin defined'

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

  console.log 'begin defined'

  window.switchLoading = (classString) ->
    loading = $("#loading")
    loading.removeClass("small big center corner")
    loading.addClass(classString)

  console.log 'switchloading defined'


  $rootScope.$on('sliding-animation-done', () ->
    console.log 'animation done'
    console.log '\n'
    switchLogs = not switchLogs
  )

  console.log 'sliding animation defined'

  showLog = (logId, manualSwitch, invert, dontPushState) ->
    console.log 'showlog'
    if logId?
      console.log 'log id'
      log = Map.data.logs[logId]
      if invert? and invert
        console.log 'invert'
        if historyChange? and historyChange
          console.log 'history change'
          if not switchLogs
            console.log 'not switchlogs -> otherlog'
            $scope.otherLog = log
          else
            console.log 'switchlogs -> log'
            $scope.log = log
        if log.profileId?
          console.log 'profileid'
          if not switchLogs
            console.log 'not switchlogs -> launch'
            renderBadge(log.profileId, '.launch')
          else
            console.log 'switchlogs -> main'
            renderBadge(log.profileId, '.main')
        else
          console.log 'no profileid'
          if not switchLogs
            console.log 'not switchlogs -> launch'
            $(".launch .log-author").html(log.profileName)
          else
            console.log 'switchlogs -> main'
            $(".main .log-author").html(log.profileName)
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
          console.log 'profile id'
          if switchLogs
            console.log 'switchlogs -> launch'
            renderBadge(log.profileId, '.launch')
          else
            console.log 'not switchlogs -> main'
            renderBadge(log.profileId, '.main')
        else
          console.log 'no profileid'
          console.log log
          console.log log.profileId
          if switchLogs
            console.log 'switchlogs -> launch'
            $(".launch .log-author").html(log.profileName)
          else
            console.log 'not switchlogs -> main'
            $(".main .log-author").html(log.profileName)
      if not dontPushState? or not dontPushState
        console.log 'pushstate'
        history.pushState(log.id, log.title, "/log/"+log.id)
      if manualSwitch? and manualSwitch
        console.log 'manual switch'
        switchLogs = not switchLogs
      Map.data.current = log.key
      changeLocation(logId)
      console.log 'finish showing log'
    else
      console.log 'no logid'

  console.log 'show log defined'

  $scope.move = (direction) ->
    if Map.data.loadingLogs == 0
      log = Map.move(direction)
      console.log 'showing log'
      showLog(log.id)
      console.log 'moving'
      $timeout(()->
        move(direction)
      ,2000)

  console.log 'move defined'

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

  console.log 'switch marker defined'

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

  console.log 'loading watch defined'

  window.fadeLoading = (fadeOut) ->
    if fadeOut
      $("#loading").addClass("fadeout")
      $("#loading").removeClass("fadein")
    else
      $("#loading").removeClass("fadeout")
      $("#loading").addClass("fadein")


  console.log 'fadeLoading defined'

  window.onpopstate = (event) ->
    if event.state?
      showLog(event.state, false, true, true)

  console.log 'onpopstate defined'

  $scope.deactivateOverlay = (view) ->
    $rootScope.overlayIsActive = false

  console.log 'deactivate overlay defined'

  $scope.changeShowing = (view) ->
    if !$("#loading").hasClass("fadein")
      $rootScope.loadingposition = "big center"
      $rootScope.showing = view
      $rootScope.overlayIsActive = true
      if $rootScope.loggedIn and not $rootScope.filesLoaded
        $rootScope.pullFiles()
      $rootScope.setShowing()

  console.log 'changeshowing defined'

  Map.initMap()

  console.log 'map inited'


])

ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope', '$timeout', 'User', ($http, $scope, $rootScope, $timeout, User) ->
    #if user is signed_in
  #$scope.map = Map
  $rootScope.showing = 'loading'
  $scope.display = 'loading'
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
      $scope.loading = false
      switchLoading("small top")
      $scope.myfiles = newFiles
      $rootScope.setShowing()
  )

  $rootScope.$on('addMapSelected', () ->
    $scope.$apply ()->
      $scope.addMapSelected = true
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
    startAddMap()

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
          google.maps.event.trigger(addMap, 'resize')
        , 200)
        returnVal = 'loggedIn'
      else
        returnVal = 'login'
        if $rootScope.overlayIsActive
          fadeLoading(true)
    angular.element("html").scope().$broadcast('update-load');
    $scope.display = returnVal

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

