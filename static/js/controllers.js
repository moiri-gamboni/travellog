// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var ctrl;

  ctrl = angular.module("mainModule.controllers", []);

  ctrl.controller("mainCtrl", [
    '$http', '$scope', '$rootScope', '$timeout', 'Map', function($http, $scope, $rootScope, $timeout, Map) {
      var dropPins, flow, loadingWatch, showLog, switchLogs, unblockBegin;
      $rootScope.overlayIsActive = false;
      switchLogs = false;
      flow = {
        isMapReady: false,
        isFirstLogReady: false,
        areLogsReady: false,
        hasBegun: false,
        arePinsDropped: false,
        canBegin: false
      };
      dropPins = function() {
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
          flow.arePinsDropped = true;
          if (flow.isFirstLogReady) {
            $(".main.fade").removeClass("fadeout");
            $(".main.fade").addClass("fadein");
            loadingWatch();
            switchLoading("small corner");
            showLog();
            return switchLogs = !switchLogs;
          }
        }, 200 * Object.keys(Map.data.logs).length);
      };
      $rootScope.$on('map-ready', function() {
        flow.isMapReady = true;
        if (flow.areLogsReady) {
          return unblockBegin();
        }
      });
      $rootScope.$on('logs-ready', function() {
        flow.areLogsReady = true;
        if (flow.isMapReady) {
          return unblockBegin();
        }
      });
      $rootScope.$on('first-log-ready', function() {
        flow.isFirstLogReady = true;
        if (flow.arePinsDropped) {
          $(".main.fade").removeClass("fadeout");
          $(".main.fade").addClass("fadein");
          loadingWatch();
          switchLoading("small corner");
          showLog();
          return switchLogs = !switchLogs;
        }
      });
      unblockBegin = function() {
        $("#loading").addClass("fadeout");
        $("#start-here").addClass("fadein");
        return flow.canBegin = true;
      };
      $scope.begin = function() {
        if (flow.canBegin) {
          $("#launch-screen, .background").addClass("hide");
          $("#container").removeClass("hide");
          fadeLoading(false);
          switchLoading("big center");
          flow.hasBegun = true;
          return $timeout(function() {
            return dropPins();
          }, 500);
        }
      };
      window.switchLoading = function(classString) {
        var loading;
        loading = $("#loading");
        loading.removeClass("small big center corner");
        return loading.addClass(classString);
      };
      $rootScope.$on('sliding-animation-done', function() {
        console.log('sliding-animation-done');
        return switchLogs = !switchLogs;
      });
      showLog = function(logId) {
        if (logId != null) {
          if (switchLogs) {
            $scope.otherLog = Map.data.logs[logId];
          } else {
            $scope.log = Map.data.logs[logId];
          }
        } else {
          if (switchLogs) {
            $scope.otherLog = Map.getCurrentLog();
            logId = $scope.otherLog.id;
          } else {
            $scope.log = Map.getCurrentLog();
            logId = $scope.log.id;
          }
        }
        return changeLocation(logId);
      };
      $scope.move = function(direction) {
        if (Map.data.loadingLogs === 0) {
          showLog(Map.move(direction).id);
          return move(direction);
        }
      };
      loadingWatch = function() {
        if (Map.data.loadingLogs === 0) {
          fadeLoading(true);
        } else {
          fadeLoading(false);
        }
        return $rootScope.$on('is-loading-log', function(event, isLoading) {
          if (isLoading) {
            return fadeLoading(false);
          } else {
            return fadeLoading(true);
          }
        });
      };
      window.fadeLoading = function(fadeOut) {
        if (fadeOut) {
          $("#loading").addClass("fadeout");
          return $("#loading").removeClass("fadein");
        } else {
          $("#loading").removeClass("fadeout");
          return $("#loading").addClass("fadein");
        }
      };
      $scope.deactivateOverlay = function(view) {
        return $rootScope.overlayIsActive = false;
      };
      $scope.changeShowing = function(view) {
        if (!$("#loading").hasClass("fadein")) {
          $rootScope.loadingposition = "big center";
          $rootScope.showing = view;
          $rootScope.overlayIsActive = true;
          console.log("going");
          console.log($rootScope.loggedIn);
          console.log($rootScope.filesLoaded);
          if ($rootScope.loggedIn && !$rootScope.filesLoaded) {
            $rootScope.pullFiles();
            return console.log("working");
          }
        }
      };
      return Map.initMap();
    }
  ]);

  ctrl.controller("MyFilesController", [
    '$http', '$scope', '$rootScope', 'User', function($http, $scope, $rootScope, User) {
      $rootScope.showing = 'loading';
      $rootScope.loggedIn = false;
      $scope.myfiles = [];
      $scope.selectedFile = null;
      $scope.addMapSelected = false;
      $scope.loading = false;
      $rootScope.filesLoaded = false;
      $scope.loadingMessage = "";
      $scope.completeUrl = "";
      $scope.successMessage = "";
      $rootScope.$on('loggedIn', function(event, resp) {
        console.log("finishing login");
        User = resp;
        console.log(User);
        $rootScope.$apply(function() {
          return $rootScope.loggedIn = true;
        });
        $scope.loading = true;
        $scope.$apply(function() {
          $scope.loadingMessage = "Loading your drive (this could take a while)";
          console.log("loading message updated");
          return console.log($scope.loadingMessage);
        });
        if ($rootScope.overlayIsActive) {
          return $rootScope.pullFiles();
        }
      });
      $rootScope.$on('addMapSelected', function() {
        return $scope.$apply(function() {
          return $scope.addMapSelected = true;
        });
      });
      $scope.submitAgain = function() {
        return $scope.complete = false;
      };
      $scope.isSelected = function(file) {
        return file === $scope.selectedFile;
      };
      $scope.selectFile = function(file) {
        return $scope.selectedFile = file;
      };
      $rootScope.pullFiles = function() {
        console.log("starting to pull data");
        $rootScope.filesLoaded = true;
        retrieveAllFiles(function(resp) {
          console.log("got response");
          $scope.$apply(function() {
            $scope.myfiles = resp;
            return $scope.loading = false;
          });
          return angular.element("html").scope().$broadcast('update-load');
        });
        return startAddMap();
      };
      $scope.$watch(function() {
        return $scope.loading;
      }, function() {
        return $scope.getShowing();
      });
      $scope.getShowing = function() {
        var returnVal;
        if ($rootScope.showing === "help") {
          if ($rootScope.overlayIsActive) {
            fadeLoading(true);
          }
          return $rootScope.showing;
        }
        returnVal = "";
        if ($rootScope.showing === "addFile") {
          if ($scope.loading) {
            if ($rootScope.overlayIsActive) {
              fadeLoading(false);
            }
            returnVal = 'loading';
          } else if ($scope.complete) {
            if ($rootScope.overlayIsActive) {
              fadeLoading(true);
            }
            returnVal = 'complete';
          } else if ($rootScope.loggedIn) {
            if ($rootScope.overlayIsActive) {
              fadeLoading(true);
            }
            setTimeout(function() {
              return google.maps.event.trigger(addMap, 'resize');
            }, 200);
            returnVal = 'loggedIn';
          } else {
            returnVal = 'login';
            if ($rootScope.overlayIsActive) {
              fadeLoading(true);
            }
          }
        }
        angular.element("html").scope().$broadcast('update-load');
        console.log(returnVal);
        return returnVal;
      };
      $scope.canSubmit = function() {
        return $scope.addMapSelected && ($scope.selectedFile != null);
      };
      $scope.activateOverlay = function(view) {
        $rootScope.overlayIsActive = true;
        return $scope.changeShowing(view);
      };
      $scope.overlayActive = function() {
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
        if (User.isPlusUser != null) {
          payload.profileId = User.id;
        } else {
          payload.profileName = User.name;
        }
        $scope.loadingMessage = "Sharing your story!";
        $scope.loading = true;
        return makePublic(payload.gdriveId, function(resp) {
          return addToTravellog(payload.gdriveId, function(resp) {
            return $http({
              method: "POST",
              url: "/logs",
              data: payload
            }).success(function(data, status, headers, config) {
              $scope.loading = false;
              $scope.complete = true;
              if (data.status === 200) {
                $scope.completeUrl = "http://www.travellog.io/log/" + $scope.selectedFile.id;
                return $scope.successMessage = "Congratulations, your travel log has been uploaded and is available at:";
              } else {
                $scope.completeUrl = "";
                return $scope.successMessage = data.error;
              }
            }).error(function(data, status, headers, config) {});
          });
        });
      };
      return $scope.startLogin = function() {
        if (!$rootScope.loggedIn) {
          $scope.loading = true;
          return $scope.loadingMessage = "Logging you in";
        }
      };
    }
  ]);

}).call(this);
