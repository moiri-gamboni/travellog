"use strict"
ctrl = angular.module("mainModule.controllers", [])

ctrl.controller("mainCtrl", ['$http', '$scope', 'Map', ($http, $scope, Map) ->
  #$scope.map = Map
])
ctrl.controller("MyFilesController", ['$http', '$scope', ($http, $scope) ->
	if user is signed in:
  #$scope.map = Map
	  console.log("yo")
	  #get request
	  $scope.myfilesa = [{"name": "yes"}, {"name": "no"}, {"name": "maybe"}, {"name": "first"}, {"name": "middle"}, {"name": "last"}, {"name": "yes"}, {"name": "no"}, {"name": "maybe"}, {"name": "first"}, {"name": "middle"}, {"name": "last"} , {"name": "yes"}, {"name": "no"}, {"name": "maybe"}, {"name": "first"}, {"name": "middle"}, {"name": "last"}]
	  console.log $scope.myfilesa
	  upload = (id) ->
	  	#post request
	else:
		populate sign-in page
])
ctrl.controller("SignInController", ['$http', '$scope', ($http, $scope) ->
	sign_in = (user) ->
		# blah
])