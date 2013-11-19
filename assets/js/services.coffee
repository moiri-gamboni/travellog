"use strict"

srv = angular.module("mainModule.services", [])

srv.factory('test', [ () ->
  return true
])

srv.factory('Country', ['$http', '$rootScope', ($http, $rootScope) ->
  factory =
    getCountries: () ->
      console.log("getCountries call")
      #return $http({
       # method: 'GET',
       # url: url,
       # responseType: "application/json"})
      return $http.get(window.location.protocol + "//" + window.location.host + "/countries")

    getCountry: (countryName) ->
      console.log("getCountry call")
      return $http.get(
        window.location.protocol + "//" + window.location.host + "/countries",
        {params:{id:countryName}}
      )

    loadCountry: (fileIds, countryName, countryIndex) ->
      @fileIds = fileIds
      @countryName = countryName
      @loadedLogs = null
      @countryIndex = countryIndex
      @logInit = if fileIds.length < 3 then fileIds.length else 3

      @loadLog = () ->
        $http.get(
          window.location.protocol + "//" + window.location.host + "/logs/:id:country",
          {params:
            id:fileIds[fileIds.length - 1]
            country: countryName}
        ).success((data, status, headers, config) ->
          loadedLogs.push(data.result)
          fileIds.pop()
          logInit--
          if logInit is 0
            $rootScope.$broadcast('country-init', countryIndex)
        )

      @getLog = () ->
        if loadedLogs.length isnt 0
          return loadedLogs.pop()
        else if fileIds.length isnt 0
          loadLog()
          return 1
        else return 0

      for i in [1..3]
        if fileIds.length isnt 0
          loadLog()

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


  Country.getCountries().success((data, status, headers, config) ->
    console.log("getCountries success")
    console.log(data)
    service.availableCountries = shuffle(data.countries)
    current = [100, 1000]
    $rootScope.$on('country-init', (event, countryIndex) ->
      for i in [-1..1]
        map[100+countryIndex][1000+i] = service.loadedCountries[countryIndex].getLog()
    )
    for i in [0..2]
      Country.getCountry(data.countries[data.countries.length - 1]).success((data, status, headers, config) ->
        console.log("getCountry success")
        console.log(data)
        service.loadedCountries.push(new Country.loadCountry(data.logs, service.availableCountries.pop(), i))
      )
  )

  return service
])


