"use strict"

srv = angular.module('myApp.services', [])

srv.service('Map', ['$scope', '$rootScope', 'Country', ($scope, $rootScope, Country) ->
  service =
    map: []
    current: null

  $scope.$on('country.update', (event) ->
    if
  return service
])

srv.factory('Country', ['$rootScope', '$http', ($rootScope, $http) ->
  service =
    name: null
    id: null
    savedLogs: []
    availableLogs: []

    getCountry: (id) ->
      $http.get(
        window.location.protocol + "//" + window.location.host + "/countries/:id",
        {params:{id:id}}
      ).success((data, status, headers, config) ->
        if data.result?
          console.log(data.result)
          @name = data.result.name
          @id = data.result.id
          @availableLogs = data.result.logs
          $rootScope.$broadcast('country.init')
      ).error((data, status, headers, config) ->
        console.log(data)
      )

    getLog: () ->
      id = availableLogs[availableLogs.length -1]
      $http.get(
        window.location.protocol + "//" + window.location.host + "/countries/:id",
        {params:{id:id}}
      ).success((data, status, headers, config) ->
        if data.result?
          console.log(data.result)
          @savedLogs.push(data.result.log)
          @availableLogs.pop()
          $rootScope.$broadcast('country.add')
          if @availableLogs.length == 0
            $rootScope.$broadcast('country.end')
      ).error((data, status, headers, config) ->
        console.log(data)
      )
  return service
])
