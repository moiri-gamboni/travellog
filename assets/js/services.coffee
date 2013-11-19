"use strict"

srv = angular.module('myApp.services', [])

srv.factory('Map', ['$scope', '$rootScope', 'Country', ($scope, $rootScope, Country) ->

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
    service.availableCountries = shuffle(data.result)
    current = [100, 1000]
    $rootScope.$on('country-init', (event, countryIndex) ->
      for i in [-1..1]
        map[100+countryIndex][1000+i] = loadedCountries[countryIndex].getLog()
    )
    for i in [0..2]
      Country.getCountry(data.result[data.result.length - 1]).success((data, status, headers, config) ->
        loadedCountries.push(new Country.loadCountry(data.result, service.availableCountries.pop(), i))
  )

  return service
])

srv.factory('Country', ['$http', '$rootScope', ($http, $rootScope) ->
  factory =
    getCountries: () ->
      return $http.get(
        window.location.protocol + "//" + window.location.host + "/countries",
        {params:{id:countryName}}
      )

    getCountry: (countryName) ->
      return $http.get(
        window.location.protocol + "//" + window.location.host + "/countries/:id",
        {params:{id:countryName}}
      )

    loadCountry: (fileIds, countryName, countryIndex) ->
      @fileIds = fileIds
      @countryName = countryName
      @loadedLogs = null
      @countryIndex = countryIndex
      @logInit = fileIds.length < 3 ? fileIds.length : 3

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
