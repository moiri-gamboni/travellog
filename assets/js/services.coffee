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


