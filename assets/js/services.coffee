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
      return $postRequest('/logs' + {gdriveId: googleDriveId, lat: lat, lng:lng, country:country})

  return factory
])



srv.factory('Map', ['$q', '$http', '$rootScope', 'Resources', ($q, $http, $rootScope, Resources) ->
  res = Resources
  factory =
    logs: {}
    countries: {}
    sortedLogs: {}
    current: null
    loadingLogs: 0

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
        @loadingLogs++
        $rootScope.$broadcast('getting-logs', @loadingLogs)
        res.getLog(logId).success((data) ->
          factory.logs[data.log.id].title = data.log.title
          factory.logs[data.log.id].profileId = data.log.profileId
          factory.logs[data.log.id].profileName = data.log.profileName
          factory.logs[data.log.id].body = data.log.body
          deferred.resolve(factory.logs[data.log.id])
        ).error((data) ->
          console.log 'getlog error'
          deferred.reject({msg:'getLog error', err:data})
        ).finally(() ->
          factory.loadingLogs--
          $rootScope.$broadcast('getting-logs', factory.loadingLogs)
        )
        return deferred.promise


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

    initMap: (logId) ->
      deferred = $q.defer()
      res.getLogs().success((data) ->
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
        factory.sortedLogs.lng = data.logs.slice().sort((b, a) ->
          return b.lng-a.lng
        )
        for log, i in factory.sortedLogs.lng
          factory.sortedLogs.lng[i] = log.id
          factory.logs[log.id].key = [i, factory.logs[log.id].key[1]]
        if not logId?
          keys = Object.keys(factory.logs)
          factory.current = factory.logs[keys[(Math.random()*keys.length)>>0]].key
          logId = factory.sortedLogs.lng[factory.current[0]]
        else
          factory.current = factory.logs[logId].key
        factory.getLog(logId).then((logdata) ->
          deferred.notify(1)
          factory.getClosestLogs(factory.current)
        ).then((data) ->
          deferred.notify(2)
          deferred.resolve(factory.logs)
        )
      )
      return deferred.promise

  return factory
])

srv.factory('User', [() ->
  return
])
