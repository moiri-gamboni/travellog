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
        newCurrent = factory.data.logs[factory.data.latLogs[(factory.data.current[1]+change)%factory.data.latLogs.length].id].key
      else
        newCurrent = factory.data.logs[factory.data.lngLogs[(factory.data.current[0]+change)%factory.data.latLogs.length].id].key
      getClosestLogs(newCurrent)
      changeCurrent = (newCurrent)-> factory.data.current = newCurrent
      $timeout(changeCurrent(newCurrent), 100)


    getLog: (logId) ->
      console.log(logId)
      console.log(factory.data.logs)
      if not factory.data.logs[logId].body?
        get = $http.get(
          window.location.protocol + "//" + window.location.host + "/logs",
          {params:{id:logId}}
        ).success((data, status, headers, config)->
          console.log(data)
          console.log(factory.data.logs[data.log.id])
          factory.data.logs[data.log.id].body = data.log.body
        )

    getClosestLogs: (around) ->
      for direction in ['N','E','S','W']
        factory.getLog(factory.getClosestLocation(around, direction))

    getClosestLocation: (from, direction) ->
      tempKey = from
      tempLog = null
      changeFirst = if direction in ['N', 'E'] then +1 else -1
      if direction in ['N', 'S']
        #assume N
        #move up
        tempKey[1] = (tempKey[1] + changeFirst) % factory.data.latLogs.length
        tempLog = factory.data.latLogs[tempKey[1]]

        while (tempKey isnt from)
          #assume L
          changeSecond = if tempLog.lng > from.lng then -1 else +1
          while(not factory.inRange(from, tempLog, direction))
            #move right
            tempKey[0] = (tempKey[0] + changeSecond) % factory.data.lngLogs.length
            tempLog = factory.data.lngLogs[tempKey[0]]
            tempKey = factory.data.logs[tempLog.id].key

          last = tempKey
          #move down
          while(factory.inRange(from, tempLog, direction) or tempKey isnt from)
            last = tempKey
            tempKey[1] = (tempKey[1] - changeFirst) % factory.data.latLogs.length
            tempLog = factory.data.latLogs[tempKey[1]]
            tempKey = factory.data.logs[tempLog.id].key

      else
        #assume E
        #move right
        tempKey[0] = (tempKey[0] + changeFirst) % factory.data.lngLogs.length
        tempLog = factory.data.lngLogs[tempKey[0]]

        while (tempKey isnt from)
          #assume D
          changeSecond = if tempLog.lat > from.lat then -1 else +1
          while(not factory.inRange(from, tempLog, direction))
            #move up
            tempKey[1] = (tempKey[1] + changeSecond) % factory.data.latLogs.length
            tempLog = factory.data.latLogs[tempKey[1]]
            tempKey = factory.data.logs[tempLog.id].key

          last = tempKey
          #move left
          while(factory.inRange(from, tempLog, direction) or tempKey isnt from)
            last = tempKey
            tempKey[0] = (tempKey[0] - changeFirst) % factory.data.lngLogs.length
            tempLog = factory.data.lngLogs[tempKey[0]]
            tempKey = factory.data.logs[tempLog.id].key

      return last

    inRange: (from, to, direction) ->
      console.log("from")
      console.log(from)
      console.log("to")
      console.log(to)
      from = factory.data.lngLogs[from[0]]
      to = factory.data.lngLogs[to[0]]
      console.log(from)
      console.log(to)
      gradient = (to.lat-from.lat)/(to.lng-from.lng)
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
          mapData.latLogs = data.logs.sort((a, b) ->
            return b.lat-a.lat
          )
          for log, i in mapData.latLogs
            mapData.logs[log.id] =
              id: log.id
              body: null
              lat: log.lat
              lng: log.lng
              key: [null, i]
          mapData.lngLogs = data.logs.sort((a, b) ->
            return b.lng-a.lng
          )
          for log, i in mapData.lngLogs
            mapData.logs[log.id].key = [i, mapData.logs[log.id].key[1]]

          keys = Object.keys(mapData.logs)
          current = mapData.logs[keys[(Math.random()*keys.length)>>0]].key
          id = mapData.lngLogs[current[0]].id
          factory.getLog(id)
          factory.getClosestLogs(current)

      factory.getLogs(getLogsCallback(factory.data))

  return factory

>>>>>>> d35088287adc02a19db9d62f73bd034dabdf5b20
])

srv.factory('Country', ['$http', '$rootScope', ($http, $rootScope) ->
  factory =
    getCountries: () ->
      #console.log("getCountries call")
      #return $http({
       # method: 'GET',
       # url: url,
       # responseType: "application/json"})
      return $http.get(window.location.protocol + "//" + window.location.host + "/countries")

    getCountry: (countryName) ->
      #console.log("getCountry call")
      return $http.get(
        window.location.protocol + "//" + window.location.host + "/countries",
        {params:{id:countryName}}
      )

    loadCountry: (fileIds, countryName, countryIndex) ->
      @countryIndex = countryIndex
      $rootScope.$broadcast('country-init')
      @fileIds = fileIds
      @countryName = countryName
      @loadedLogs = []
      @logInit = if fileIds.length < 3 then fileIds.length else 3
      #console.log("countryIndex for "+@countryName+" : "+@countryIndex)
      console.log("fileIds.length for "+@countryName+" : "+@fileIds.length)
      console.log("logInit for "+@countryName+" : "+@logInit)

      @loadLog = () ->
        console.log("loadLog for "+@countryName)
        return $http.get(
          window.location.protocol + "//" + window.location.host + "/logs",
          {params:
            id:@fileIds[@fileIds.length - 1]
            country: @countryName}
        )

      @getLog = () ->
        console.log("getLog")
        if @loadedLogs.length isnt 0
          return @loadedLogs.pop()
        else if @fileIds.length isnt 0
          @loadLog().success((data, status, headers, config) =>
            console.log("logInit for "+@countryName+" : "+@logInit)
            @loadedLogs.push(data.result)
            @fileIds.pop()
            @logInit--
            if @logInit is 0
              console.log("DONE")
              console.log(@countryIndex)
              $rootScope.$broadcast('country-finished-init', @countryIndex)
          )
          return 1
        else return 0

      for i in [1..3]
        @getLog()
      return @

  return factory
])

srv.factory('Map', ['$rootScope', 'Country', ($rootScope, Country) ->

  #from: http://stackoverflow.com/a/6274398
  shuffle = (array) ->
    temp
    index
    counter = array.length

    # While there are elements in the array
    while (counter--)
      # Pick a random index
      index = (Math.random() * counter) | 0

      # And swap the last element with it
      temp = array[counter]
      array[counter] = array[index]
      array[index] = temp

      return array

  service =
    availableCountries: []
    loadedCountries: []
    current: []
    map: []
    countryIndex: 0


  Country.getCountries().success((data, status, headers, config) ->
    service.availableCountries = shuffle(data.countries)
    current = [100, 100]
    $rootScope.$on('country-init', (event) ->
      service.countryIndex++
    )
    $rootScope.$on('country-finished-init', (event, countryIndex) ->
      for i in [-1..1]
        console.log(100+countryIndex)
        if not service.map[100+countryIndex]?
          service.map[100+countryIndex] = []
        service.map[100+countryIndex][100+i] = service.loadedCountries[countryIndex].getLog()
        console.log(service.map)
    )
    for i in [1..3]
      countries = data.countries
      callback = (i) ->
        return (data, status, headers, config) =>
          country = countries[countries.length - i]
          service.loadedCountries.push(Country.loadCountry(data.logs, country, service.countryIndex))
      Country.getCountry(data.countries[data.countries.length - i]).success(callback(i)
      ).error((data, status, headers, config) =>
        console.log(data)
      )

  )
  return service
])


