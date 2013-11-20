"use strict"

srv = angular.module("mainModule.services", [])

srv.factory('test', [ () ->
  return true
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
      @data =
        countryIndex: countryIndex
        fileIds: fileIds
        countryName: countryName
        loadedLogs: []
        logInit: if fileIds.length < 3 then fileIds.length else 3
      console.log("countryIndex for "+@data.countryName+" : "+@data.countryIndex)
      #console.log("fileIds for "+@data.countryName+" : "+@data.fileIds)
      #console.log("fileIds.length for "+@data.countryName+" : "+@data.fileIds.length)
      #console.log("logInit for "+@data.countryName+" : "+@data.logInit)
      #console.log(@data)
      $rootScope.$broadcast('country-init')

      @loadLog = (fileId) ->
        #console.log("loadLog for "+@data.countryName)
        #console.log("fileId for loadLog of "+@data.countryName+" : "+fileId)
        callback = (countryData) =>
          return (data, status, headers, config) =>
            #console.log("loadLog callback")
            #console.log(data)
            #console.log(status)
            #console.log(headers)
            #console.log(config)
            #console.log("logInit for "+countryData.countryName+" : "+countryData.logInit)
            countryData.loadedLogs.push(data.log)
            countryData.fileIds.pop()
            countryData.logInit--
            if countryData.logInit is 0
              console.log("logInit DONE for "+countryData.countryName)
              console.log(countryData.loadedLogs)
              $rootScope.$broadcast('country-finished-init', countryData.countryIndex)

        return $http.get(
          window.location.protocol + "//" + window.location.host + "/logs",
          {params:
            id:fileId}
        ).success(callback(@data))

      @getLog = () ->
        console.log("getLog")
        console.log(@data.loadedLogs.length)
        if @data.loadedLogs.length isnt 0
          log = @data.loadedLogs.pop()
          #console.log(log)
          return log
        else if @data.fileIds.length isnt 0
          #@loadLog()
          return 1
        else return 0

      #console.log(@data.logInit)
      for i in [1..@data.logInit]
        fileId = @data.fileIds[@data.fileIds.length - i]
        #console.log(@data.fileIds.length - i)
        #console.log(fileId)
        @loadLog(fileId)
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
      console.log(countryIndex)
      for i in [-1..1]
        #console.log(100+countryIndex)
        log = service.loadedCountries[countryIndex].getLog()
        console.log(log)
        if not service.map[100+countryIndex]?
          service.map[100+countryIndex] = []
        service.map[100+countryIndex][100+i] = log
        #console.log(service.map)
    )
    for i in [1..3]
      countries = data.countries
      callback = (i) ->
        return (data, status, headers, config) =>
          #console.log(data)
          country = countries[countries.length - i]
          service.loadedCountries.push(Country.loadCountry(data.logs, country, service.countryIndex))
      Country.getCountry(data.countries[data.countries.length - i]).success(callback(i)
      ).error((data, status, headers, config) =>
        console.log(data)
      )

  )
  return service
])


