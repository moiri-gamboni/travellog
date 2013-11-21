// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var ctrl;

  ctrl = angular.module("mainModule.controllers", []);

  ctrl.controller("mainCtrl", [
    '$http', '$scope', '$rootScope', '$timeout', 'Map', function($http, $scope, $rootScope, $timeout, Map) {
      console.log("A");
      Map.initMap();
      $rootScope.$on('map-init', function() {
        return console.log("init");
      });
      $scope.$watch(function() {
        return Map.data.current;
      }, function(current) {
        return $scope.log = Map.getCurrentLog();
      });
      $scope.getLog = function() {
        return $scope.log = Map.getCurrentLog();
      };
      $scope.move = function(direction) {
        return Map.move(direction);
      };
      return $scope.dropPins = function() {
        var dropPin, i, log, _i, _len, _ref, _results;
        dropPin = function(log) {
          return function() {
            return placeMarkerMiniMap(log);
          };
        };
        _ref = Object.keys(Map.data.logs);
        _results = [];
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          log = _ref[i];
          _results.push($timeout(dropPin(log), 200 * i));
        }
        return _results;
      };
    }
  ]);

  ctrl.controller("MyFilesController", [
    '$http', '$scope', '$rootScope', 'User', function($http, $scope, $rootScope, User) {
      var _this = this;
      $scope.myfiles = {
        "title": "empty"
      };
      $scope.selectedFile = null;
      $scope.addMapSelected = false;
      $rootScope.$on('loggedIn', function(event, resp) {
        User = resp;
        $scope.$apply(function() {
          return $scope.loggedIn = true;
        });
        return retrieveAllFiles(function(resp) {
          return $scope.$apply(function() {
            return $scope.myfiles = resp;
          });
        });
      });
      $rootScope.$on('addMapSelected', function() {
        return $scope.$apply(function() {
          return $scope.addMapSelected = true;
        });
      });
      $scope.isSelected = function(file) {
        return file === $scope.selectedFile;
      };
      $scope.selectFile = function(file) {
        console.log(User);
        return $scope.selectedFile = file;
      };
      $scope.canSubmit = function() {
        return $scope.addMapSelected && ($scope.selectedFile != null);
      };
      return $scope.upload = function() {};
    }
  ]);

}).call(this);
