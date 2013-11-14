"use strict"

srv = angular.module('myApp.services', [])

srv.factory('Map', ['$scope', '$rootScope', 'Country' ,($scope, $rootScope, Country) ->
  map =
    countries: []
    current: 0
    availableCountries: []

    initMap: () ->
      $http.get(
        window.location.protocol + "//" + window.location.host + "/countries/"
      ).success((data, status, headers, config) ->
        if data.result?
          console.log(data.result)
          @availableCountries = shuffle(data.result)
          for i in [0..5]
            if @availableCountries.length isnt 0
              country = new Country(@availableCountries.pop())
            else break
            for j in [0..5]
              if country.hasLogs()
                country.getLog()
              else break
            @countries.push(country)
          @current = 1
      ).error((data, status, headers, config) ->
        console.log(data)
      )
  return map
])

srv.factory('Country',['$http', 'id', ($http, id) ->
  country =
    name: ""
    id: id
    savedLogs: []
    availableLogs: []
    hasLogs: => @availableLogs.length!=0

    getCountry: () ->
      country = null
      $http.get(
        window.location.protocol + "//" + window.location.host + "/country/",
        {params:{id:id}}
      ).success((data, status, headers, config) ->
        if data.result?
          console.log(data.result)
          @name = data.result.name
          @availableLogs = shuffle(data.result.logs)
          for j in [0..2]
            if @hasLogs()
              @getLog()
            else break
      ).error((data, status, headers, config) ->
        console.log(data)
      )

    getLog: () ->
      id =  @availableLogs[@availableLogs.length -1]
      $http.get(
        window.location.protocol + "//" + window.location.host + "/logs/",
        {params:{id:id}}
      ).success((data, status, headers, config) ->
        if data.result?
          console.log(data.result)
          @savedLogs.push(data.result.log)
          @availableLogs.pop()
      ).error((data, status, headers, config) ->
        console.log(data)
      )
  return country
])

