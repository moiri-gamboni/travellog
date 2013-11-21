// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var ctrl;

  ctrl = angular.module("mainModule.controllers", []);

  ctrl.controller("mainCtrl", [
    '$http', '$scope', '$rootScope', '$timeout', 'Map', function($http, $scope, $rootScope, $timeout, Map) {
      var switchLogs;
      Map.initMap();
      switchLogs = true;
      $rootScope.loadingClass = "";
      $rootScope.loadingSize = "";
      $scope.loadingClass = function() {
        var classString, loadSize;
        classString = $rootScope.loadingClass;
        loadSize = $rootScope.loadingSize;
        return classString + " " + loadSize;
      };
      $scope.dropPins = function() {
        var dropPin, i, log, logId, _ref;
        dropPin = function(log) {
          return function() {
            return placeMarkerMiniMap(log);
          };
        };
        i = 0;
        _ref = Map.data.logs;
        for (logId in _ref) {
          log = _ref[logId];
          $timeout(dropPin(log), 200 * i);
          i++;
        }
        return $timeout(function() {
          console.log($scope.log.id);
          return changeLocation($scope.log.id);
        }, 2800);
      };
      $rootScope.$on('animation-done', function() {
        console.log("firing");
        return switchLogs = !switchLogs;
      });
      $rootScope.$on('gotFirstLog', function() {
        $scope.log = Map.getCurrentLog();
        return $scope.dropPins();
      });
      $scope.getLog = function() {
        return $scope.log = Map.getCurrentLog();
      };
      return $scope.move = function(direction) {
        if (switchLogs) {
          $scope.otherLog = Map.move(direction);
          return changeLocation($scope.otherLog.id);
        } else {
          $scope.log = Map.move(direction);
          return changeLocation($scope.log.id);
        }
      };
    }
  ]);

  ctrl.controller("MyFilesController", [
    '$http', '$scope', '$rootScope', function($http, $scope, $rootScope) {
      var callback, callback2,
        _this = this;
      $rootScope.showing = 'loading';
      console.log('going false');
      $scope.loggedIn = false;
      console.log($scope);
      $scope.myfiles = {
        "title": "empty"
      };
      $scope.selectedFile = null;
      $scope.addMapSelected = false;
      $scope.overlayIsActive = false;
      console.log($scope.myfiles);
      $scope.loadingMessage = "";
      $scope.completeUrl = "";
      callback = function(passedScope) {
        return function(event, name, profileId) {
          console.log("you've been logged in");
          passedScope.loggedIn = true;
          passedScope.loading = false;
          retrieveAllFiles(function(resp) {
            return passedScope.$apply(function() {
              return passedScope.myfiles = resp;
            });
          });
          startAddMap();
          console.log(passedScope.showing);
          if (profileId) {
            passedScope.hasGoogle = true;
            return $scope.profileId = profileId;
          } else {
            passedScope.hasGoogle = false;
            return $scope.name = name;
          }
        };
      };
      $rootScope.$on('loggedIn', callback($scope));
      callback2 = function(passedScope) {};
      $rootScope.$on('addMapSelected', function() {
        console.log("working away to make mapSelected True");
        return $scope.$apply(function() {
          return $scope.addMapSelected = true;
        });
      });
      $scope.isSelected = function(file) {
        return file === $scope.selectedFile;
      };
      $scope.selectFile = function(file) {
        console.log("selecting file!");
        return $scope.selectedFile = file;
      };
      $scope.changeShowing = function(view) {
        console.log(view);
        $rootScope.showing = view;
        return console.log($rootScope.showing);
      };
      $scope.getShowing = function() {
        if ($rootScope.showing === "help") {
          return $rootScope.showing;
        }
        if ($rootScope.showing === "addFile") {
          if ($scope.loading) {
            return 'loading';
          } else if ($scope.complete) {
            return 'complete';
          } else if ($scope.loggedIn) {
            setTimeout(function() {
              return google.maps.event.trigger(addMap, 'resize');
            }, 200);
            return 'loggedIn';
          } else {
            return 'login';
          }
        }
      };
      $scope.canSubmit = function() {
        console.log("checking submit" + $scope.addMapSelected + ($scope.selectedFile != null));
        return $scope.addMapSelected && ($scope.selectedFile != null);
      };
      $scope.activateOverlay = function(view) {
        $scope.overlayIsActive = true;
        return $scope.changeShowing(view);
      };
      $scope.overlayActive = function() {
        console.log("activate overlay");
        return $scope.overlayIsActive;
      };
      $scope.upload = function() {
        var payload;
        if (!$scope.canSubmit()) {
          return;
        }
        payload = {
          gdriveId: $scope.selectedFile.id,
          lat: addMapMarker.position.lat(),
          lng: addMapMarker.position.lng()
        };
        if ($scope.hasGoogle) {
          payload.profileId = $scope.profileId;
        } else {
          payload.profileName = $scope.name;
        }
        $scope.loadingMessage = "Sending your message up!";
        $scope.loading = true;
        $rootScope.loadingClass = "bigLoadCenter";
        $rootScope.loadingSize = "large";
        return $http({
          method: "POST",
          url: "/logs",
          data: payload
        }).success(function(data, status, headers, config) {
          if (data.status === 200) {
            $scope.loading = false;
            $scope.complete = true;
            return $scope.completeUrl = "http://www.travellog.io/log/" + $scope.selectedFile.id;
          } else {
            return console.log("no idea what happened");
          }
        }).error(function(data, status, headers, config) {});
      };
      return $scope.startLogin = function() {
        if (!$scope.loggedIn) {
          $scope.loading = true;
          $rootScope.loadingClass = "bigLoadCenter";
          $rootScope.loadingSize = "large";
          return $scope.loadingMessage = "Logging you in";
        }
      };
    }
  ]);

}).call(this);
