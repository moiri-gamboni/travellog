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
        canBegin: false,
        urlLogLoadWatch: null
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
            if ($rootScope.urlEntered != null) {
              Map.getLog($rootScope.urlEntered);
              return flow.urlLogLoadWatch = $rootScope.$on('is-loading-log', function(event, isLoading) {
                if (!isLoading) {
                  showLog($rootScope.urlEntered, true);
                  return flow.urlLogLoadWatch();
                }
              });
            } else {
              return showLog(Map.getCurrentLog().id, true);
            }
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
          if ($rootScope.urlEntered != null) {
            Map.getLog($rootScope.urlEntered);
            return flow.urlLogLoadWatch = $rootScope.$on('is-loading-log', function(event, isLoading) {
              if (!isLoading) {
                showLog($rootScope.urlEntered, true);
                return flow.urlLogLoadWatch();
              }
            });
          } else {
            return showLog(Map.getCurrentLog().id, true);
          }
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
        console.log('animation done');
        return switchLogs = !switchLogs;
      });
      showLog = function(logId, manualSwitch, invert, dontPushState) {
        var log;
        if (logId != null) {
          log = Map.data.logs[logId];
          if ((invert != null) && invert) {
            if ((typeof historyChange !== "undefined" && historyChange !== null) && historyChange) {
              if (!switchLogs) {
                $scope.otherLog = log;
              } else {
                $scope.log = log;
              }
            }
            if (log.profileId != null) {
              if (!switchLogs) {
                renderBadge(log.profileId, '.launch');
              } else {
                renderBadge(log.profileId, '.main');
              }
            } else {
              if (!switchLogs) {
                renderBadge(log.profileName, '.launch');
              } else {
                renderBadge(log.profileName, '.main');
              }
            }
            $scope.$apply();
          } else {
            if (switchLogs) {
              $scope.otherLog = log;
            } else {
              $scope.log = log;
            }
            if (log.profileId != null) {
              if (switchLogs) {
                renderBadge(log.profileId, '.launch');
              } else {
                renderBadge(log.profileId, '.main');
              }
            } else {
              if (switchLogs) {
                renderBadge(log.profileName, '.launch');
              } else {
                renderBadge(log.profileName, '.main');
              }
            }
          }
          if ((dontPushState == null) || !dontPushState) {
            history.pushState(log.id, log.title, "/log/" + log.id);
          }
          if ((manualSwitch != null) && manualSwitch) {
            switchLogs = !switchLogs;
          }
          Map.data.current = log.key;
          return changeLocation(logId);
        }
      };
      $scope.move = function(direction) {
        var log;
        if (Map.data.loadingLogs === 0) {
          log = Map.move(direction);
          showLog(log.id);
          return move(direction);
        }
      };
      $rootScope.$on('switch-marker', function(event, logId) {
        var watch;
        if (Map.data.logs[logId].body != null) {
          return showLog(logId, false, true);
        } else {
          Map.getLog(logId);
          return watch = $rootScope.$on('is-loading-log', function(event, isLoading) {
            if (!isLoading) {
              showLog(logId, false, true);
              return watch();
            }
          });
        }
      });
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
      window.onpopstate = function(event) {
        if (event.state != null) {
          return showLog(event.state, false, true, true);
        }
      };
      $scope.deactivateOverlay = function(view) {
        return $rootScope.overlayIsActive = false;
      };
      $scope.changeShowing = function(view) {
        if (!$("#loading").hasClass("fadein")) {
          console.log("clicked");
          $rootScope.loadingposition = "big center";
          $rootScope.showing = view;
          $rootScope.overlayIsActive = true;
          if ($rootScope.loggedIn && !$rootScope.filesLoaded) {
            $rootScope.pullFiles();
          }
          return $rootScope.setShowing();
        }
      };
      return Map.initMap();
    }
  ]);

  ctrl.controller("MyFilesController", [
    '$http', '$scope', '$rootScope', '$timeout', 'User', function($http, $scope, $rootScope, $timeout, User) {
      $rootScope.showing = 'loading';
      $scope.display = 'loading';
      $rootScope.loggedIn = false;
      $scope.myfiles = [];
      $scope.numFilesMessage = "";
      $scope.filesLoaded = false;
      $scope.selectedFile = null;
      $scope.addMapSelected = false;
      $scope.loading = false;
      $rootScope.filesLoaded = false;
      $scope.loadingMessage = "";
      $scope.completeUrl = "";
      $scope.successMessage = "";
      $rootScope.$on('loggedIn', function(event, resp) {
        User = resp;
        $rootScope.loggedIn = true;
        $scope.loading = true;
        $rootScope.setShowing();
        $scope.$apply(function() {
          return $scope.loadingMessage = "Loading your drive";
        });
        if ($rootScope.overlayIsActive) {
          return $rootScope.pullFiles();
        }
      });
      $rootScope.$on("partialFilesLoaded", function(event, newFiles) {
        return $scope.$apply(function() {
          $scope.numFilesMessage = newFiles.length + " Files Loaded";
          $scope.loading = false;
          switchLoading("small top");
          $scope.myfiles = newFiles;
          return $rootScope.setShowing();
        });
      });
      $rootScope.$on('addMapSelected', function() {
        return $scope.$apply(function() {
          return $scope.addMapSelected = true;
        });
      });
      $scope.submitAgain = function() {
        $scope.complete = false;
        return $rootScope.setShowing();
      };
      $scope.isSelected = function(file) {
        return file === $scope.selectedFile;
      };
      $scope.selectFile = function(file) {
        return $scope.selectedFile = file;
      };
      $rootScope.pullFiles = function() {
        $rootScope.filesLoaded = true;
        retrieveAllFiles(function(resp) {
          $scope.$apply(function() {
            $scope.filesLoaded = true;
            $scope.numFilesMessage = "All " + $scope.myfiles.length + " files loaded";
            fadeLoading(true);
            return $timeout(function() {
              return switchLoading("center big");
            }, 500);
          });
          return angular.element("html").scope().$broadcast('update-load');
        });
        return startAddMap();
      };
      $rootScope.setShowing = function() {
        var returnVal;
        console.log("running");
        returnVal = "";
        if ($rootScope.showing === "help") {
          if ($rootScope.overlayIsActive) {
            fadeLoading(true);
            returnVal = $rootScope.showing;
          }
        } else if ($rootScope.showing === "addFile") {
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
            if ($rootScope.overlayIsActive && !$scope.filesLoaded) {
              fadeLoading(false);
            } else if ($rootScope.overlayIsActive && $scope.filesLoaded) {
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
        return $scope.display = returnVal;
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
        $rootScope.setShowing();
        return makePublic(payload.gdriveId, function(resp) {
          return addToTravellog(payload.gdriveId, function(resp) {
            return $http({
              method: "POST",
              url: "/logs",
              data: payload
            }).success(function(data, status, headers, config) {
              $scope.loading = false;
              $scope.complete = true;
              $rootScope.setShowing();
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
          $scope.loadingMessage = "Logging you in";
          return $rootScope.setShowing();
        }
      };
    }
  ]);

}).call(this);
