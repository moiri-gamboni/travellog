"use strict"

srv = angular.module("mainModule.services", [])

srv.factory('Map', ['$http', '$rootScope', ($http, $rootScope) ->
  factory =
    data:
      logs: {}
      countries: {}
      latLogs: []
      lngLogs: []
      current: null
      loadingLogs: 0

    getCurrentLog: () ->
      console.log 'get current log'
      if factory.data.current? and factory.data.lngLogs? and factory.data.lngLogs[factory.data.current[0]]?
        return factory.data.logs[factory.data.lngLogs[factory.data.current[0]].id]
      else
        return null

    getLogs: (success) ->
      get = $http.get(
        window.location.protocol + "//" + window.location.host + "/logs"
      ).success(success).error((data, status, headers, config)->
        console.log 'getLogs error'
        console.log data
      )

    move: (direction) ->
      console.log 'move'
      change = if direction in ['N', 'E'] then +1 else -1
      if direction in ['N', 'S']
        newCurrentLog = factory.data.logs[factory.data.latLogs[mod(factory.data.current[1]+change,factory.data.latLogs.length)].id]
      else
        newCurrentLog = factory.data.logs[factory.data.lngLogs[mod(factory.data.current[0]+change,factory.data.latLogs.length)].id]
      factory.getClosestLogs(newCurrentLog.key)
      factory.data.current = newCurrentLog.key
      console.log 'move done'
      return newCurrentLog


    getLog: (logId, callback) ->
      console.log 'get log'
      if not factory.data.logs[logId].body?
        console.log 'has no body'
        factory.data.loadingLogs++
        $rootScope.$broadcast('is-loading-log', true)
        get = $http.get(
          window.location.protocol + "//" + window.location.host + "/logs",
          {params:{id:logId}}
        )
        if callback?
          get.success((data, status, headers, config)->
            console.log 'get log success'
            factory.data.loadingLogs--
            callback(data, status, headers, config)
            if factory.data.loadingLogs == 0
              $rootScope.$broadcast('is-loading-log', false)
          ).error((data, status, headers, config)->
            console.log 'get log error'
            console.log data
            factory.data.loadingLogs--
            if factory.data.loadingLogs == 0
              $rootScope.$broadcast('is-loading-log', false)
          )
        else
          get.success((data, status, headers, config)->
            console.log 'get log success'
            console.log data.log
            factory.data.loadingLogs--
            factory.data.logs[data.log.id].title = data.log.title
            factory.data.logs[data.log.id].profileId = data.log.profileId
            factory.data.logs[data.log.id].profileName = data.log.profileName
            factory.data.logs[data.log.id].body = data.log.body
            if factory.data.loadingLogs == 0
              $rootScope.$broadcast('is-loading-log', false)
          ).error((data, status, headers, config)->
            console.log 'get log error'
            console.log data
            factory.data.loadingLogs--
            if factory.data.loadingLogs == 0
              $rootScope.$broadcast('is-loading-log', false)
          )

    getClosestLogs: (logKey) ->
      console.log 'get get closests logs'
      for direction in ['N','E','S','W']
        change = if direction in ['N', 'E'] then +1 else -1
        if direction in ['N', 'S']
          location = factory.data.logs[factory.data.latLogs[mod(logKey[1]+change,factory.data.latLogs.length)].id]
        else
          location = factory.data.logs[factory.data.lngLogs[mod(logKey[0]+change,factory.data.lngLogs.length)].id]
        factory.getLog(location.id)

    getClosestLocation: (from, direction) ->
      tempKey = from.slice()
      change = if direction in ['N', 'E'] then 1 else (-1)
      breakLoop = false
      for wrapNumber in [0,1,2]
        break if breakLoop
        if direction in ['N', 'S']
          i = Math.abs(mod(from[1] + change, factory.data.latLogs.length))
          while i isnt from[1]
            tempKey[1] = i
            tempLog = factory.data.latLogs[tempKey[1]]
            tempKey = factory.data.logs[tempLog.id].key
            return tempKey
            if factory.inRange(from, tempKey, direction, wrapNumber)
              breakLoop = true
              break
            i = Math.abs(mod(i + change, factory.data.latLogs.length))

        else
          i = Math.abs(mod(from[0] + change,factory.data.lngLogs.length))
          while i isnt from[0]
            tempKey[0] = i
            tempLog = factory.data.lngLogs[tempKey[0]]
            tempKey = factory.data.logs[tempLog.id].key
            return tempKey
            if factory.inRange(from, tempKey, direction, wrapNumber)
              breakLoop = true
              break
            i = Math.abs(mod(i + change, factory.data.lngLogs.length))

      return tempKey

    inRange: (from, to, direction, wrapNumber) ->
      from = factory.data.lngLogs[from[0]]
      to = factory.data.lngLogs[to[0]]
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

    # one off map function to update all logs
    updateAllLogs: () ->
      1 + 1

    initMap: () ->
      getLogsCallback = (mapData) ->
        return (data, status, headers, config) ->
          console.log 'get logs success'
          $rootScope.$broadcast('logs-ready')
          mapData.latLogs = data.logs.slice().sort((b, a) ->
            return b.lat-a.lat
          )
          console.log 'sort lats'
          for log, i in mapData.latLogs
            mapData.logs[log.id] =
              id: log.id
              body: null
              title: null
              profileId: null
              profileName: null
              lat: log.lat
              lng: log.lng
              key: [null, i]
          console.log 'build logs data'
          mapData.lngLogs = data.logs.slice().sort((b, a) ->
            return b.lng-a.lng
          )
          console.log 'sort lngs'
          for log, i in mapData.lngLogs
            mapData.logs[log.id].key = [i, mapData.logs[log.id].key[1]]
          console.log 'rebuild logs data'

          keys = Object.keys(mapData.logs)
          mapData.current = mapData.logs[keys[(Math.random()*keys.length)>>0]].key
          id = mapData.lngLogs[factory.data.current[0]].id
          factory.getLog(id,
            (data, status, headers, config)->
              console.log 'get first log success'
              factory.data.logs[data.log.id].title = data.log.title
              factory.data.logs[data.log.id].profileId = data.log.profileId
              factory.data.logs[data.log.id].profileName = data.log.profileName
              factory.data.logs[data.log.id].body = data.log.body
              $rootScope.$broadcast('first-log-ready')
          )
          console.log 'map init before closest logs done'
          factory.getClosestLogs(factory.data.current)
          console.log 'map init after closest logs'

      factory.getLogs(getLogsCallback(factory.data))
      console.log 'map init done'

  return factory

])

srv.factory('User', [() ->
  return
])
