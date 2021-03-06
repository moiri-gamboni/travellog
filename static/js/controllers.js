// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var ctrl;

  ctrl = angular.module("mainModule.controllers", []);

  ctrl.controller("mainCtrl", [
    '$q', '$http', '$scope', '$rootScope', '$timeout', 'LogService', 'MapService', function($q, $http, $scope, $rootScope, $timeout, LogService, MapService) {
      var arePinsDropped, canBegin, dropPins, isFirstLogReady, loadingWatch, showLog, slide, switchLogs;
      $rootScope.overlayIsActive = false;
      switchLogs = false;
      isFirstLogReady = false;
      arePinsDropped = false;
      canBegin = false;
      $scope.log = null;
      $scope.otherLog = null;
      $rootScope.miniMapMgrLoaded = $q.defer();
      dropPins = function() {
        var country, deferred, deferredPins, dropPin, i, loader, promisedPins, _i, _j, _len, _len1, _ref;
        deferredPins = [];
        promisedPins = [];
        i = 0;
        loader = $("#loading-text");
        loader.css({
          display: "block"
        });
        dropPin = function(i, country) {
          return function() {
            loader.html(country.title);
            MapService.miniMapMgr.addMarker(country, 0, 2);
            return deferredPins[i].resolve();
          };
        };
        _ref = MapService.countryMarkers;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          country = _ref[_i];
          if (country.title !== "Other" && country.title !== "None") {
            (function(country) {
              deferredPins[i] = $q.defer();
              return $timeout(dropPin(i, country), 250 * i);
            })(country);
            i++;
          }
        }
        for (_j = 0, _len1 = deferredPins.length; _j < _len1; _j++) {
          deferred = deferredPins[_j];
          promisedPins.push(deferred.promise);
        }
        return $q.all(promisedPins);
      };
      $scope.deactivateOverlay = function(view) {
        $("#overlay, #overlay-content").removeClass("fadein");
        $rootScope.overlayIsActive = false;
        $scope.changeShowing("small corner");
        fadeLoading(true);
        return $rootScope.setShowing();
      };
      $scope.begin = function() {
        if (canBegin) {
          $("#launch-screen").addClass("fadeout");
          $("#container").removeClass("hide");
          fadeLoading(false);
          switchLoading("big center");
          return $timeout(function() {
            return dropPins().then(function() {
              return $timeout(function() {
                arePinsDropped = true;
                $("#loading-text").css({
                  display: "none"
                });
                if (isFirstLogReady) {
                  $(".main.fade").removeClass("fadeout");
                  $(".main.fade").addClass("fadein");
                  loadingWatch();
                  switchLoading("small corner");
                  return showLog(LogService.getCurrentLog().id, {
                    firstLoad: true,
                    manualSwitch: true,
                    renderBadgeInMain: true
                  });
                }
              }, 1000);
            });
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
        return switchLogs = !switchLogs;
      });
      $scope.safeApply = function(fn) {
        var phase;
        phase = this.$root.$$phase;
        if (phase === "$apply" || phase === "$digest") {
          if (fn && (typeof fn === "function")) {
            return fn();
          }
        } else {
          return this.$apply(fn);
        }
      };
      slide = function(direction) {
        var deferred, launchIn, mainOut, prepare, screenHeight, screenWidth, time1, time2, time3, topDistance, windowHeight, windowWidth;
        deferred = $q.defer();
        windowHeight = $(".main").height();
        windowWidth = $(".main").width();
        screenHeight = $(window).height();
        screenWidth = $(window).width();
        topDistance = parseInt($(".main").css("top"), 10);
        if (direction === "N") {
          prepare = {
            "left": "0",
            "top": -windowHeight
          };
          launchIn = {
            "y": windowHeight + topDistance,
            x: 0
          };
          mainOut = {
            "y": screenHeight,
            x: 0
          };
        } else if (direction === "S") {
          prepare = {
            "left": "0",
            "top": screenHeight
          };
          launchIn = {
            "y": -(screenHeight - topDistance),
            x: 0
          };
          mainOut = {
            "y": -screenHeight,
            x: 0
          };
        } else if (direction === "W") {
          prepare = {
            "left": -screenWidth,
            "top": topDistance
          };
          launchIn = {
            "x": screenWidth,
            y: 0
          };
          mainOut = {
            "x": screenWidth,
            y: 0
          };
        } else if (direction === "E") {
          prepare = {
            "left": screenWidth,
            "top": topDistance
          };
          launchIn = {
            "x": -screenWidth,
            y: 0
          };
          mainOut = {
            "x": -screenWidth,
            y: 0
          };
        }
        $(".launch").attr({
          "style": ""
        }).css(prepare).children(".log-wrapper");
        time1 = 100;
        time2 = 800;
        time3 = 100;
        $timeout(function() {
          $(".launch").transition(launchIn, 800);
          $(".main").transition(mainOut, 800);
          return setTimeout(function() {
            $(".log-details").removeClass("animate").toggleClass("main launch").attr({
              "style": ""
            });
            angular.element("html").scope().$broadcast("sliding-animation-done");
            return setTimeout(function() {
              $(".launch .log-author").css({
                "opacity": 0
              });
              return deferred.resolve();
            }, time3);
          }, time2);
        }, time1);
        return deferred.promise;
      };
      showLog = function(logId, options) {
        var fn, log;
        if (options == null) {
          options = {};
        }
        if (options.manualSwitch == null) {
          options.manualSwitch = false;
        }
        if (options.invert == null) {
          options.invert = false;
        }
        if (options.pushState == null) {
          options.pushState = true;
        }
        if (options.notChangeMarker == null) {
          options.changeMarker = true;
        }
        if (options.renderBadgeInMain == null) {
          options.renderBadgeInMain = false;
        }
        if (options.firstLoad == null) {
          options.firstLoad = false;
        }
        if (options.removeRendering == null) {
          options.removeRendering = false;
        }
        if (logId != null) {
          log = LogService.logs[logId];
          document.title = "Travellog - " + log.title;
          $("#g-comments").remove();
          if (options.invert) {
            if (!switchLogs) {
              $scope.otherLog = log;
              $scope.safeApply();
            } else {
              $scope.log = log;
              $scope.safeApply();
            }
          } else {
            if (switchLogs) {
              $scope.otherLog = log;
            } else {
              $scope.log = log;
            }
          }
          if (options.firstLoad || options.invert) {
            $(".main .log-wrapper").scrollTop(0).children(".log-content").append("<div id='g-comments'></div>");
          } else {
            $(".launch .log-wrapper").scrollTop(0).children(".log-content").append("<div id='g-comments'></div>");
          }
          if (options.manualSwitch) {
            switchLogs = !switchLogs;
          }
          if (options.pushState) {
            history.pushState(log.id, log.title, "/log/" + log.id);
          }
          LogService.current = log.key;
          fn = function() {
            if (log.profileId != null) {
              if (options.renderBadgeInMain !== options.removeRendering) {
                renderBadge(log.profileId, '.main');
              } else {
                renderBadge(log.profileId, '.launch');
              }
            } else {
              if (options.renderBadgeInMain) {
                $(".main .log-author").html(log.profileName);
              } else {
                $(".launch .log-author").html(log.profileName);
              }
            }
            if (options.changeMarker) {
              MapService.changeLocation(logId);
            }
            gapi.plus.render("plus-button", {
              action: "share",
              align: "right",
              annotation: "bubble",
              href: document.location.href
            });
            return gapi.comments.render('g-comments', {
              href: window.location,
              width: 624,
              first_party_property: 'BLOGGER',
              view_type: 'FILTERED_POSTMOD'
            });
          };
          if (!options.removeRendering) {
            return fn();
          } else {
            return fn;
          }
        } else {
          return console.log('no logid');
        }
      };
      $scope.move = function(direction) {
        var fn, log;
        if (LogService.logsLoading === 0) {
          LogService.move(direction);
          log = LogService.getCurrentLog();
          fn = showLog(log.id, {
            removeRendering: true
          });
          return slide(direction).then(function() {
            return fn();
          });
        }
      };
      $rootScope.$on('switch-marker', function(event, logId, isCountry) {
        var watch;
        if (isCountry) {
          logId = LogService.countries[logId].logs[0];
        }
        $(".main .log-author").css({
          "opacity": 0
        });
        if (LogService.logs[logId].body != null) {
          return showLog(logId, {
            invert: true,
            renderBadgeInMain: true
          });
        } else {
          LogService.getLog(logId);
          LogService.getClosestLogs(LogService.logs[logId].key);
          return watch = $rootScope.$on('logs-loading', function() {
            if (LogService.logsLoading === 0) {
              showLog(logId, {
                invert: true,
                renderBadgeInMain: true
              });
              return watch();
            }
          });
        }
      });
      loadingWatch = function() {
        var f;
        f = function() {
          if (LogService.logsLoading === 0) {
            return fadeLoading(true);
          } else {
            return fadeLoading(false);
          }
        };
        f();
        return $rootScope.$on('logs-loading', function() {
          return f();
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
          return showLog(event.state, {
            invert: true,
            pushState: false
          });
        }
      };
      $scope.changeShowing = function(view) {
        if (!$("#loading").hasClass("fadein")) {
          $rootScope.showing = view;
          $rootScope.overlayIsActive = true;
          if ($rootScope.loggedIn && !$rootScope.filesLoaded) {
            $rootScope.pullFiles();
          }
          return $rootScope.setShowing();
        }
      };
      MapService.init();
      return LogService.initCountries().then(function(data) {
        return LogService.initLogs();
      }).then(function(logs) {
        $("#loading").addClass("fadeout");
        $("#start-here").addClass("fadein");
        canBegin = true;
        return LogService.initLog($rootScope.urlEntered);
      }).then(function() {
        return $rootScope.miniMapMgrLoaded.promise;
      }).then(function(log) {
        isFirstLogReady = true;
        if (arePinsDropped) {
          $(".main.fade").removeClass("fadeout");
          $(".main.fade").addClass("fadein");
          loadingWatch();
          switchLoading("small corner");
          showLog(LogService.getCurrentLog().id, {
            manualSwitch: true,
            renderBadgeInMain: true
          });
        }
        return LogService.getClosestLogs(LogService.getCurrentLog().key);
      }).then(function(data) {});
    }
  ]);

  ctrl.controller("MyFilesController", [
    '$http', '$scope', '$rootScope', '$timeout', 'User', 'MapService', function($http, $scope, $rootScope, $timeout, User, MapService) {
      $rootScope.showing = 'loading';
      $scope.display = 'loading';
      $rootScope.loggedIn = false;
      $scope.myfiles = [];
      $scope.numFilesMessage = "";
      $scope.filesLoaded = false;
      $scope.selectedFile = null;
      $scope.addLogServiceSelected = false;
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
            if (resp.length > 0) {
              $scope.numFilesMessage = "All " + $scope.myfiles.length + " files loaded";
            } else {
              $scope.numFilesMessage = "You have no google documents in your drive";
              $("#file-loading-message").css({
                color: "red"
              });
            }
            fadeLoading(true);
            return $timeout(function() {
              return switchLoading("center big");
            }, 500);
          });
          return angular.element("html").scope().$broadcast('update-load');
        });
        return MapService.startAddMap();
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
              return google.maps.event.trigger(MapService.addMap, 'resize');
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
        return MapService.addMapMarker && ($scope.selectedFile != null);
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
          $(".white.small").css({
            color: "red"
          });
          $timeout(function() {
            return $(".white.small").css("");
          }, 2000);
          return;
        }
        switchLoading("big center");
        payload = {
          gdriveId: $scope.selectedFile.id,
          lat: MapService.addMapMarker.position.lat(),
          lng: MapService.addMapMarker.position.lng()
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
          var location;
          location = new google.maps.LatLng(payload.lat, payload.lng);
          return MapService.reverseGeocode(location, function(formatted_address, countryName) {
            var _this = this;
            payload.country = countryName;
            return MapService.geocode(countryName, function(location) {
              payload.countryLat = location.lat();
              payload.countryLng = location.lng();
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
                    $scope.completeUrl = window.location.protocol + "//" + window.location.host + "/log/" + $scope.selectedFile.id;
                    return $scope.successMessage = "Congratulations, your travel log has been uploaded and is available at:";
                  } else {
                    $scope.completeUrl = "";
                    return $scope.successMessage = data.error;
                  }
                }).error(function(data, status, headers, config) {});
              });
            });
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
