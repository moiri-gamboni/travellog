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
      $scope.log = null;
      $scope.otherLog = null;
      dropPins = function() {
        var dropPin, i, log, logId, _ref;
        console.log('drop pins');
        dropPin = function(log) {
          return function() {
            return placeMarkerMiniMap(log);
          };
        };
        i = 0;
        _ref = Map.logs;
        for (logId in _ref) {
          log = _ref[logId];
          $timeout(dropPin(log), 200 * i);
          i++;
        }
        return $timeout(function() {
          var watch;
          console.log('drop pins timeout');
          flow.arePinsDropped = true;
          if (flow.isFirstLogReady) {
            console.log('first log is ready from drop pins');
            $(".main.fade").removeClass("fadeout");
            $(".main.fade").addClass("fadein");
            loadingWatch();
            switchLoading("small corner");
            if ($rootScope.urlEntered != null) {
              console.log('entered url');
              if (Map.logs[$rootScope.urlEntered].body == null) {
                Map.getLog($rootScope.urlEntered);
                Map.getClosestLogs(Map.logs[$rootScope.urlEntered].key);
                return watch = $rootScope.$on('getting-logs', function(event, totalLogs) {
                  console.log('url watch');
                  if (totalLogs === 0) {
                    console.log('stop watch');
                    showLog($rootScope.urlEntered, true, null, null, null, true);
                    return watch();
                  }
                });
              } else {
                return showLog($rootScope.urlEntered, true);
              }
            } else {
              return showLog(Map.getCurrentLog().id, true, null, null, null, true);
            }
          }
        }, 200 * Object.keys(Map.logs).length);
      };
      $rootScope.$on('map-ready', function() {
        flow.isMapReady = true;
        if (flow.areLogsReady) {
          return unblockBegin();
        }
      });
      unblockBegin = function() {
        $("#loading").addClass("fadeout");
        $("#start-here").addClass("fadein");
        return flow.canBegin = true;
      };
      $scope.begin = function() {
        if (flow.canBegin) {
          $("#launch-screen").addClass("fadeout");
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
        console.log('\n');
        return switchLogs = !switchLogs;
      });
      showLog = function(logId, manualSwitch, invert, dontPushState, notChangeMarker, renderBadgeInMain) {
        var log;
        console.log('showlog');
        if (logId != null) {
          console.log('log id');
          log = Map.logs[logId];
          if ((invert != null) && invert) {
            console.log('invert');
            console.log('history change');
            if (!switchLogs) {
              console.log('not switchlogs -> otherlog');
              $scope.otherLog = log;
            } else {
              console.log('switchlogs -> log');
              $scope.log = log;
            }
            $scope.$apply();
          } else {
            console.log('no invert');
            if (switchLogs) {
              console.log('switchlogs -> otherlog');
              $scope.otherLog = log;
            } else {
              console.log('not switchlogs -> log');
              $scope.log = log;
            }
          }
          if (log.profileId != null) {
            console.log('profileid');
            if ((renderBadgeInMain != null) && renderBadgeInMain) {
              console.log("rendering badge in main");
              renderBadge(log.profileId, '.main');
            } else {
              console.log("rendering badge in launch");
              renderBadge(log.profileId, '.launch');
            }
          } else {
            console.log('no profileid');
            if ((renderBadgeInMain != null) && renderBadgeInMain) {
              $(".main .log-author").html(log.profileName);
            } else {
              $(".launch .log-author").html(log.profileName);
            }
          }
          if ((dontPushState == null) || !dontPushState) {
            console.log('pushstate');
            history.pushState(log.id, log.title, "/log/" + log.id);
          }
          if ((manualSwitch != null) && manualSwitch) {
            console.log('manual switch');
            switchLogs = !switchLogs;
          }
          Map.current = log.key;
          if ((notChangeMarker == null) || !notChangeMarker) {
            changeLocation(logId);
          }
          return console.log('finish showing log');
        } else {
          return console.log('no logid');
        }
      };
      $scope.move = function(direction) {
        var log;
        if (Map.loadingLogs === 0) {
          log = Map.move(direction);
          console.log(log);
          console.log('showing log');
          showLog(log.id, null, null, null, true);
          console.log('moving');
          move(direction);
          return $timeout(function() {
            return changeLocation(log.id);
          }, 500);
        }
      };
      $rootScope.$on('switch-marker', function(event, logId) {
        var watch;
        console.log("switching marker");
        $(".main" + " .log-author").css({
          "opacity": 0
        });
        if (Map.logs[logId].body != null) {
          console.log("body exists");
          return showLog(logId, false, true, false, false, true);
        } else {
          console.log("fetching body");
          Map.getLog(logId);
          Map.getClosestLogs(Map.logs[logId].key);
          return watch = $rootScope.$on('getting-logs', function(event, isLoading) {
            if (!isLoading) {
              showLog(logId, false, true, false, false, true);
              return watch();
            }
          });
        }
      });
      loadingWatch = function() {
        if (Map.loadingLogs === 0) {
          fadeLoading(true);
        } else {
          fadeLoading(false);
        }
        return $rootScope.$on('getting-logs', function(event, isLoading) {
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
          $rootScope.loadingposition = "big center";
          $rootScope.showing = view;
          $rootScope.overlayIsActive = true;
          if ($rootScope.loggedIn && !$rootScope.filesLoaded) {
            $rootScope.pullFiles();
          }
          return $rootScope.setShowing();
        }
      };
      return Map.initMap().then(function(logs) {
        return $rootScope.logs = logs;
      }, null, function(progress) {
        var watch;
        switch (progress) {
          case 0:
            flow.areLogsReady = true;
            if (flow.isMapReady) {
              return unblockBegin();
            }
            break;
          case 1:
            console.log('first log ready');
            flow.isFirstLogReady = true;
            if (flow.arePinsDropped) {
              console.log('pins are dropped from first log ready');
              $(".main.fade").removeClass("fadeout");
              $(".main.fade").addClass("fadein");
              loadingWatch();
              switchLoading("small corner");
              if ($rootScope.urlEntered != null) {
                console.log('entered url');
                if (Map.logs[$rootScope.urlEntered].body == null) {
                  Map.getLog($rootScope.urlEntered);
                  Map.getClosestLogs(Map.logs[$rootScope.urlEntered].key);
                  return watch = $rootScope.$on('getting-logs', function(event, isLoading) {
                    console.log('url watch');
                    if (!isLoading) {
                      console.log('stop url watch');
                      showLog($rootScope.urlEntered, true, null, null, null, true);
                      return watch();
                    }
                  });
                } else {
                  return showLog($rootScope.urlEntered, true);
                }
              } else {
                console.log("no url entered");
                return showLog(Map.getCurrentLog().id, true, null, null, null, true);
              }
            } else {
              return console.log('pins not dropped yet');
            }
            break;
          case 2:
            return console.log('other logs ready');
        }
      });
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
      $scope.startedFileLoad = false;
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
          if (!$scope.startedFileLoad) {
            $scope.loading = false;
            switchLoading("small top");
          }
          $scope.startedFileLoad = true;
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
        switchLoading("big center");
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
