"use strict"

srv = angular.module("mainModule.services", [])

srv.factory('Resources', ['$http', '$rootScope', ($http, $rootScope) ->
  factory =
    getRequest: (endpoint, params) ->
      promise = null
      if params?
        promise = $http.get(
          window.location.protocol + "//" + window.location.host + endpoint,
          {params:params}
        )
      else
        promise = $http.get(
          window.location.protocol + "//" + window.location.host + endpoint,
        )
      promise.error((data, status, headers, config) ->
        console.log data
        alert("Unknown Error, please try again later.")
      )
      return promise

    postRequest: (endpoint, params) ->
      promise = null
      if params?
        promise = $http.post(
          window.location.protocol + "//" + window.location.host + endpoint,
          params
        )
      else
        promise = $http.post(
          window.location.protocol + "//" + window.location.host + endpoint,
        )
      promise.error((data, status, headers, config) ->
        console.log data
        alert("Unknown Error, please try again later.")
      )
      return promise

    deleteRequest: (endpoint, params) ->
      promise = null
      if params?
        promise = $http.delete(
          window.location.protocol + "//" + window.location.host + endpoint,
          {params:params}
        )
      else
        promise = $http.delete(
          window.location.protocol + "//" + window.location.host + endpoint,
        )
      promise.error((data, status, headers, config) ->
        console.log data
        alert("Unknown Error, please try again later.")
      )
      return promise

    getCountries: () ->
      return @getRequest('/countries')
    getLogs: () ->
      return @getRequest('/logs')
    getLog: (logId) ->
      return @getRequest('/logs',{id:logId})
    createLog: (googleDriveId, lat, lng, country) ->
      return $postRequest('/logs' + {gdriveId: googleDriveId, lat: lat,\
        lng:lng, country:country})

  return factory
])

srv.factory('LogService', ['$q', '$http', '$rootScope', 'Resources',\
'MapService', '$timeout',\
($q, $http, $rootScope, Resources, MapService, $timeout) ->
  res = Resources
  factory =
    logs: {}
    countries: {}
    sortedLogs: {}
    current: null
    logsLoading: 0

    getCurrentLog: () ->
      if @current? and @sortedLogs.lng? and @sortedLogs.lng[@current[0]]?
        return @logs[@sortedLogs.lng[@current[0]]]
      else
        return null

    move: (direction) ->
      change = if direction in ['N', 'E'] then +1 else -1
      if direction in ['N', 'S']
        newCurrentLog = @logs[@sortedLogs.lat[mod(@current[1]+change,@sortedLogs.lat.length)]]
      else
        newCurrentLog = @logs[@sortedLogs.lng[mod(@current[0]+change,@sortedLogs.lat.length)]]
      @current = newCurrentLog.key
      return @getClosestLogs(newCurrentLog.key)


    getLog: (logId) ->
      deferred = $q.defer()
      if not @logs[logId].body?
        factory.logsLoading++
        res.getLog(logId).success((data) ->
          factory.logs[data.log.id].title = data.log.title
          factory.logs[data.log.id].profileId = data.log.profileId
          factory.logs[data.log.id].profileName = data.log.profileName
          factory.logs[data.log.id].body = data.log.body
          deferred.resolve(factory.logs[data.log.id])
        ).error((data) ->
          console.log 'getlog error'
          console.log data
          deferred.reject({msg:'getLog error', err:data})
        ).finally(()->
          factory.logsLoading--
          $rootScope.broadcast('logs-loading', factory.logsLoading)
        )
      else
        deferred.reject('Log is already loaded')
      return deferred.promise

    # geolocate all logs (for backwards compatibility)
    refreshAllLogsLocation: () ->
      i = 0
      for k, log of @logs
        do (log) =>
          $timeout( () =>
            location = new google.maps.LatLng(log.lat, log.lng)
            MapService.reverseGeocode(location, (formatted_address, countryName) =>
              if not @countries[countryName]?
                MapService.geocode(countryName, (location) =>
                  $.post(window.location.origin + "/log/" + log.id + "/edit",
                  JSON.stringify({
                    country: countryName
                    countryLat: location.lat()
                    countryLng: location.lng()
                  }), (resp) ->
                    console.log("updated log with new geocode")
                  )
                )
              else
                console.log("attempting geocode with existing country " + countryName)
                $.post(window.location.origin + "/log/" + log.id + "/edit",
                  JSON.stringify({country: countryName}), (resp) ->
                    console.log("updated log")
                )
            )
          , 3000*i)
        i++

    getClosestLogs: (logKey) ->
      logPromises = []
      for direction in ['N','E','S','W']
        change = if direction in ['N', 'E'] then +1 else -1
        if direction in ['N', 'S']
          location = @logs[@sortedLogs.lat[mod(logKey[1]+change,@sortedLogs.lat.length)]]
        else
          location = @logs[@sortedLogs.lng[mod(logKey[0]+change,@sortedLogs.lng.length)]]
        logPromises.push(@getLog(location.id))
      return $q.all(logPromises)

    getClosestLocation: (from, direction) ->
      tempKey = from.slice()
      change = if direction in ['N', 'E'] then 1 else (-1)
      breakLoop = false
      for wrapNumber in [0,1,2]
        break if breakLoop
        if direction in ['N', 'S']
          i = Math.abs(mod(from[1] + change, @sortedLogs.lat.length))
          while i isnt from[1]
            tempKey[1] = i
            tempLog = @sortedLogs.lat[tempKey[1]]
            tempKey = @logs[tempLog.id].key
            return tempKey
            if @inRange(from, tempKey, direction, wrapNumber)
              breakLoop = true
              break
            i = Math.abs(mod(i + change, @sortedLogs.lat.length))

        else
          i = Math.abs(mod(from[0] + change,@sortedLogs.lng.length))
          while i isnt from[0]
            tempKey[0] = i
            tempLog = @sortedLogs.lng[tempKey[0]]
            tempKey = @logs[tempLog.id].key
            return tempKey
            if @inRange(from, tempKey, direction, wrapNumber)
              breakLoop = true
              break
            i = Math.abs(mod(i + change, @sortedLogs.lng.length))

      return tempKey

    inRange: (from, to, direction, wrapNumber) ->
      from = @sortedLogs.lng[from[0]]
      to = @sortedLogs.lng[to[0]]
      wrapDirection = if direction in ['N', 'E'] then 1 else -1
      gradient = ((to.lat + wrapDirection * wrapNumber * 90)-from.lat)/((to.lng + wrapDirection * wrapNumber * 180)-from.lng)

      if direction in ['N', 'S']
        if gradient <= -0.5 or gradient >= 0.5
          if direction is 'N'
            return to.lat >= from.lat
          else
            return to.lat <= from.lat
        else
          return false
      else
        if gradient >= -0.5 and gradient <= 0.5
          if direction is 'E'
            return to.lng >= from.lng
          else
            return to.lng <= from.lng
        else
          return false

    initLogs: () ->
      deferred = $q.defer()
      res.getCountries().then((data) ->
        for country in data.data.countries
          country.logs = []
          factory.countries[country.id] = country
          MapService.placeMarkerMiniMap(country, true)
        return res.getLogs()
      ).then((data) =>
        data = data.data
        deferred.notify(0)
        factory.sortedLogs.lat = data.logs.slice().sort((b, a) ->
          return b.lat-a.lat
        )
        for log, i in factory.sortedLogs.lat
          factory.sortedLogs.lat[i] = log.id
          factory.logs[log.id] =
            id: log.id
            body: null
            title: null
            profileId: null
            profileName: null
            lat: log.lat
            lng: log.lng
            key: [null, i]
          factory.countries[log.country].logs.push(log.id)
          # add to the marker
          MapService.placeMarkerMiniMap(log)
        try
          # if the manager is already loaded
          MapService.initMarkers()
        catch
          # otherwise work when loaded
          google.maps.event.addListener(MapService.miniMapMgr, 'loaded', () ->
            MapService.initMarkers()
          )
        factory.sortedLogs.lng = data.logs.slice().sort((b, a) ->
          return b.lng-a.lng
        )
        for log, i in factory.sortedLogs.lng
          factory.sortedLogs.lng[i] = log.id
          factory.logs[log.id].key = [i, factory.logs[log.id].key[1]]
        deferred.resolve(factory.logs)
      )
      return deferred.promise

    initLog: (logId) ->
      if not logId?
        keys = Object.keys(factory.logs)
        factory.current = factory.logs[keys[(Math.random()*keys.length)>>0]].key
        logId = factory.sortedLogs.lng[factory.current[0]]
      else
        factory.current = factory.logs[logId].key
      return factory.getLog(logId)

  return factory
])

srv.factory('User', [() ->
  return
])

srv.factory('MapService', ['$rootScope', ($rootScope) ->
  factory =
    idMarkerMap: {}
    countryMarkers: []
    geocoder: null
    addMapMarker: null
    miniMap: null
    miniMapMgr: null
    addMap: null
    icons:
      current: "/static/img/pins/storyActive.png"
      visited: "/static/img/pins/storyVisited.png"
      unvisited: "/static/img/pins/storyUnvisited.png"
      country: "/static/img/pins/countryZoomedActive.png"
    currentMiniMarker: null

    init: () ->
      @geocoder = new google.maps.Geocoder()
      mapOptions =
        center: new google.maps.LatLng(20, 0)
        zoom: 1
        styles: [
          featureType: "administrative"
          stylers: [visibility: "off"]
        ,
          featureType: "transit"
          stylers: [
            color: "#000027"
          ,
            visibility: "off"
          ]
        ,
          featureType: "road"
          stylers: [visibility: "off"]
        ,
          featureType: "poi"
          stylers: [visibility: "off"]
        ,
          featureType: "administrative.locality"
          elementType: "labels.text.stroke"
          stylers: [
            visibility: "on"
          ,
            color: "#bfc5bf"
          ]
        ,
          featureType: "administrative.country"
          elementType: "labels.text.stroke"
          stylers: [
            visibility: "on"
          ,
            color: "#ffffff"
          ]
        ,
          featureType: "administrative.province"
          elementType: "labels.text.fill"
          stylers: [
            visibility: "on"
          ,
            color: "#d3d1d1"
          ]
        ,
          featureType: "water"
          stylers: [color: "#1c1c1c"]
        ,
          featureType: "landscape"
          stylers: [
            visibility: "on"
          ,
            color: "#808080"
          ]
        ]

      @miniMap = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
      @miniMapMgr = new MarkerManager(@miniMap)
      angular.element("html").scope().$broadcast("map-ready")

    startAddMap: () ->
      mapOptions =
        center: new google.maps.LatLng(0, 0)
        zoom: 1
        styles: [
          featureType: "administrative"
          stylers: [visibility: "off"]
        ,
          featureType: "transit"
          stylers: [
            color: "#000027"
          ,
            visibility: "off"
          ]
        ,
          featureType: "road"
          stylers: [visibility: "off"]
        ,
          featureType: "poi"
          stylers: [visibility: "off"]
        ,
          featureType: "administrative.locality"
          elementType: "labels.text.stroke"
          stylers: [
            visibility: "on"
          ,
            color: "#bfc5bf"
          ]
        ,
          featureType: "administrative.country"
          elementType: "labels.text.stroke"
          stylers: [
            visibility: "on"
          ,
            color: "#ffffff"
          ]
        ,
          featureType: "administrative.province"
          elementType: "labels.text.fill"
          stylers: [
            visibility: "on"
          ,
            color: "#d3d1d1"
          ]
        ,
          featureType: "water"
          stylers: [color: "#1c1c1c"]
        ,
          featureType: "landscape"
          stylers: [
            visibility: "on"
          ,
            color: "#808080"
          ]
        ]

      @addMap = new google.maps.Map(document.getElementById("add-map-canvas"), mapOptions)
      google.maps.event.addListener(@addMap, "click", (event) =>
        if @addMapMarker?
          @addMapMarker.setPosition(event.latLng)
        else
          @addMapMarker = new google.maps.Marker(
            position: event.latLng
            animation: google.maps.Animation.BOUNCE
            map: @addMap
          )
      )

    # different icons

    # click handler for a minimap item
    changeLocation: (markerId) ->
      newMarker = @idMarkerMap[markerId]

      # deselct the old one if it exists
      if @currentMiniMarker
        @currentMiniMarker.setAnimation(null)
        @currentMiniMarker.setIcon(@icons.visited)
      @currentMiniMarker = newMarker

      # set the current color
      @currentMiniMarker.setIcon(@icons.current)

      # start the bouncing
      if @currentMiniMarker.getAnimation() isnt null
        @currentMiniMarker.setAnimation(null)
      else
        @currentMiniMarker.setAnimation(google.maps.Animation.BOUNCE)

      # focus the map to the new marker
      @miniMap.panTo(@currentMiniMarker.position)
      @miniMap.setZoom(3)

    switchMiniMarker: (isCountry) ->
      $rootScope.$broadcast("switch-marker", @title, false)

    switchMiniMarkerCountry: (isCountry) ->
      $rootScope.$broadcast("switch-marker", @title, true)

    placeMarkerMiniMap: (log_object, isCountry) ->
      marker = new google.maps.Marker(
        position: new google.maps.LatLng(log_object.lat, log_object.lng)
        title: log_object.id
        icon: if isCountry then @icons.country else @icons.unvisited
      )
      if isCountry
        @countryMarkers.push(marker)
        google.maps.event.addListener(marker, "click", @switchMiniMarkerCountry)
      else
        @idMarkerMap[log_object.id] = marker
        google.maps.event.addListener(marker, "click", @switchMiniMarker)

    initMarkers: () ->
      markers = []
      for k, marker of @idMarkerMap
        markers.push(marker)
      @miniMapMgr.addMarkers(markers, 3)
      #@miniMapMgr.addMarkers(@countryMarkers, 0, 2)
      @miniMapMgr.refresh()

    # reverse geocoder modified from code example
    reverseGeocode: (latlng, callback) ->
      @geocoder.geocode
        latLng: latlng
      , (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          if results.length > 0
            formatted_address = results[0].formatted_address
            for component in results[0].address_components
              if component.types == "country" or "country" in component.types
                countryName = component.long_name
                break
            countryName ?= "Other"
            typeof callback is "function" and callback(formatted_address, countryName)
          else
            console.log "No results found"
        else
          console.log "Geocoder failed due to: " + status
          console.log latlng
          typeof callback is "function" and callback("Other", "Other")

    geocode: (countryName, callback) ->
      @geocoder.geocode
        address: countryName
      , (results, status) ->
        if status is google.maps.GeocoderStatus.OK
          #map.setCenter results[0].geometry.location
          typeof callback is "function" and callback(results[0].geometry.location)
        else
          console.log "Geocode was not successful for the following reason: " + status

  return factory
])

