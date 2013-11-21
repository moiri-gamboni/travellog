"use strict"

srv = angular.module("mainModule.services", [])

srv.factory('Map', ['$http', '$rootScope', ($http, $rootScope) ->
  factory =
    data:
      logs: {}
      latLogs: []
      lngLogs: []
      current: null

    getLogs: (success) ->
      get = $http.get(
        window.location.protocol + "//" + window.location.host + "/logs"
      ).success(success)

    move: (direction) ->
      change = if direction in ['N', 'E'] then +1 else -1
      if direction in ['N', 'S']
        newCurrent = factory.data.logs[factory.data.latLogs[mod(factory.data.current[1]+change,factory.data.latLogs.length)].id].key
      else
        newCurrent = factory.data.logs[factory.data.lngLogs[mod(factory.data.current[0]+change,factory.data.latLogs.length)].id].key
      getClosestLogs(newCurrent)
      changeCurrent = (newCurrent)-> factory.data.current = newCurrent
      $timeout(changeCurrent(newCurrent), 100)


    getLog: (logId) ->
      #console.log(logId)
      #console.log(factory.data.logs[logId])
      if not factory.data.logs[logId].body?
        get = $http.get(
          window.location.protocol + "//" + window.location.host + "/logs",
          {params:{id:logId}}
        ).success((data, status, headers, config)->
          # console.log(data)
          # console.log(factory.data.logs)
          # console.log(data)
          factory.data.logs[data.log.id].body = data.log.body
        )

    getClosestLogs: (around) ->
      for direction in ['N','E','S','W']
        location = factory.getClosestLocation(around, direction)
        factory.getLog(factory.data.lngLogs[location[0]].id)

    getClosestLocation: (from, direction) ->

      tempKey = from
      console.log(from)
      change = if direction in ['N', 'E'] then 1 else (-1)
      for wrapNumber in [0,1,2]
        if direction in ['N', 'S']
          i = Math.abs(mod(from[1] + change, factory.data.latLogs.length))
          while i isnt from[1]
            tempKey[1] = i
            tempLog = factory.data.latLogs[tempKey[1]]
            if not tempLog?
              console.log(tempKey[1])
              console.log(factory.data.latLogs)
            tempKey = factory.data.logs[tempLog.id].key
            break if factory.inRange(from, tempKey, direction, wrapNumber)
            if Math.abs(mod(i + change, factory.data.latLogs.length)) >= factory.data.latLogs.length
              console.log(i)
            else
              i = Math.abs(mod(i + change, factory.data.latLogs.length))

        else
          i = Math.abs(mod(from[0] + change,factory.data.lngLogs.length))
          while i isnt from[0]
            tempKey[0] = i
            tempLog = factory.data.lngLogs[tempKey[0]]
            if not tempLog?
              console.log(tempKey[0])
              console.log(factory.data.lngLogs)
            tempKey = factory.data.logs[tempLog.id].key
            break if factory.inRange(from, tempKey, direction, wrapNumber)

            if Math.abs(mod(i + change, factory.data.lngLogs.length)) >= factory.data.lngLogs.length
              console.log(i)
            else
              i = Math.abs(mod(i + change, factory.data.lngLogs.length))

      console.log("\n")
      console.log(from)
      console.log("closest to")
      console.log(tempKey)
      console.log("in direction "+direction)
      return tempKey


    oldgetClosestLocation: (from, direction) ->

      bestDistance = 180
      searchRange = 0
      bestPoint = null
      currentOscillation = [0,0]

      logs = factory.data.logs
      latLogs = factory.data.latLogs
      lngLogs = factory.data.lngLogs
      initialLog = latLogs[from[0]]

      # distanceWrapping = (initial, current) ->
      #   if direction == 'N'
      #     MathMath.abs(currentLog.lat-initialLog.lat) if current < initial then +90
      #   else if direction == 'S'
      #     if current > initial then return 90 else return 0
      #   else if direction == 'E'
      #     if current < initial then return 180 else return 0
      #   else if direction == 'W'
      #     if current > initial then return 180 else return 0

      while (bestPoint == null or bestDistance < 2*searchRange)
        for i in [0,1]
          loop
            currentOscillation[i] += if i == 0 then -1 else 1
            currentLog = lngLogs[currentOscillation[i]]
            searchRange = max(searchRange, MathMath.abs(currentLog.lng - initialLog.lng))
            tempDistance =
            if bestDistance > tempDistance
              bestDistance = tempDistance
            break if searchRange == MathMath.abs(currentLog.lng-initialLog.lng)

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

    initMap: () ->
      getLogsCallback = (mapData) ->
        return (data, status, headers, config) ->
          mapData.latLogs = data.logs.slice().sort((b, a) ->
            return b.lat-a.lat
          )
          console.log(mapData.latLogs)
          for log, i in mapData.latLogs
            mapData.logs[log.id] =
              id: log.id
              body: null
              lat: log.lat
              lng: log.lng
              key: [null, i]
          mapData.lngLogs = data.logs.slice().sort((b, a) ->
            return b.lng-a.lng
          )
          console.log(mapData.lngLogs)
          for log, i in mapData.lngLogs
            mapData.logs[log.id].key = [i, mapData.logs[log.id].key[1]]
          console.log(mapData.logs)

          keys = Object.keys(mapData.logs)
          current = mapData.logs[keys[(Math.random()*keys.length)>>0]].key
          id = mapData.lngLogs[current[0]].id
          factory.getLog(id)
          factory.getClosestLogs(current)

      factory.getLogs(getLogsCallback(factory.data))

  return factory

])
