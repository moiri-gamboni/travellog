"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', '$rootScope', 'Map', ($http, $scope, $rootScope, Map) ->
  Map.initMap()
  $rootScope.$on('handle-client-load', (event, apiKey)->
    console.log(apiKey)
  )
])
ctrl.controller("MyFilesController", ['$http', '$scope', '$rootScope',($http, $scope, $rootScope) ->
    #if user is signed_in
  #$scope.map = Map
  console.log('going false')
  $scope.loggedIn = false
  console.log($scope)
  $scope.myfilesa = {"title":"empty"}
  $scope.selectedFile = null
  $scope.addMapSelected = false
  console.log $scope.myfilesa
  callback = (passedScope)=>
    return (event, name, profileId)=>
      passedScope.$apply(()->
        passedScope.loggedIn = true
      )
      retrieveAllFiles((resp) ->
        passedScope.$apply(() ->
          passedScope.myfilesa = resp
        )
      )
      console.log(passedScope.loggedIn)
      if profileId
        passedScope.hasGoogle = true
      else
        passedScope.hasGoogle = false
  $rootScope.$on('loggedIn', callback($scope))

  callback2 = (passedScope) =>
    return 

  $rootScope.$on('addMapSelected', () ->
    console.log("working away to make mapSelected True")
    $scope.$apply ()->
      $scope.addMapSelected = true
  ) 
  $scope.isSelected = (file) -> 
    return file == $scope.selectedFile
  
  $scope.selectFile = (file) ->
    console.log("selecting file!")
    $scope.selectedFile = file

  $scope.canSubmit = () ->
    console.log("checking submit" + $scope.addMapSelected + $scope.selectedFile?)
    return $scope.addMapSelected and $scope.selectedFile?

  $scope.upload = () ->
    console.log("uploading: " + $scope.selectedFile + "at co-ords: " + addMapMarker.position)

])
ctrl.controller("SignInController", ['$http', '$scope', ($http, $scope) ->
    #sign_in = (user) ->
])
