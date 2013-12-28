// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var srv,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  srv = angular.module("mainModule.services", []);

  srv.factory('Resources', [
    '$http', '$rootScope', function($http, $rootScope) {
      var factory;
      factory = {
        getRequest: function(endpoint, params) {
          var promise;
          promise = null;
          if (params != null) {
            promise = $http.get(window.location.protocol + "//" + window.location.host + endpoint, {
              params: params
            });
          } else {
            promise = $http.get(window.location.protocol + "//" + window.location.host + endpoint);
          }
          promise.error(function(data, status, headers, config) {
            console.log(data);
            return alert("Unknown Error, please try again later.");
          });
          return promise;
        },
        postRequest: function(endpoint, params) {
          var promise;
          promise = null;
          if (params != null) {
            promise = $http.post(window.location.protocol + "//" + window.location.host + endpoint, params);
          } else {
            promise = $http.post(window.location.protocol + "//" + window.location.host + endpoint);
          }
          promise.error(function(data, status, headers, config) {
            console.log(data);
            return alert("Unknown Error, please try again later.");
          });
          return promise;
        },
        deleteRequest: function(endpoint, params) {
          var promise;
          promise = null;
          if (params != null) {
            promise = $http["delete"](window.location.protocol + "//" + window.location.host + endpoint, {
              params: params
            });
          } else {
            promise = $http["delete"](window.location.protocol + "//" + window.location.host + endpoint);
          }
          promise.error(function(data, status, headers, config) {
            console.log(data);
            return alert("Unknown Error, please try again later.");
          });
          return promise;
        },
        getCountries: function() {
          return this.getRequest('/countries');
        },
        getLogs: function() {
          return this.getRequest('/logs');
        },
        getLog: function(logId) {
          return this.getRequest('/logs', {
            id: logId
          });
        },
        createLog: function(googleDriveId, lat, lng, country) {
          return $postRequest('/logs' + {
            gdriveId: googleDriveId,
            lat: lat,
            lng: lng,
            country: country
          });
        }
      };
      return factory;
    }
  ]);

  srv.factory('LogService', [
    '$q', '$http', '$rootScope', 'Resources', 'MapService', '$timeout', function($q, $http, $rootScope, Resources, MapService, $timeout) {
      var factory, res;
      res = Resources;
      factory = {
        logs: {},
        countries: {},
        sortedLogs: {},
        current: null,
        loadingLogs: 0,
        getCurrentLog: function() {
          if ((this.current != null) && (this.sortedLogs.lng != null) && (this.sortedLogs.lng[this.current[0]] != null)) {
            return this.logs[this.sortedLogs.lng[this.current[0]]];
          } else {
            return null;
          }
        },
        move: function(direction) {
          var change, newCurrentLog;
          change = direction === 'N' || direction === 'E' ? +1 : -1;
          if (direction === 'N' || direction === 'S') {
            newCurrentLog = this.logs[this.sortedLogs.lat[mod(this.current[1] + change, this.sortedLogs.lat.length)]];
          } else {
            newCurrentLog = this.logs[this.sortedLogs.lng[mod(this.current[0] + change, this.sortedLogs.lat.length)]];
          }
          this.current = newCurrentLog.key;
          return this.getClosestLogs(newCurrentLog.key);
        },
        getLog: function(logId) {
          var deferred;
          deferred = $q.defer();
          if (this.logs[logId].body == null) {
            this.loadingLogs++;
            $rootScope.$broadcast('getting-logs', this.loadingLogs);
            res.getLog(logId).success(function(data) {
              factory.logs[data.log.id].title = data.log.title;
              factory.logs[data.log.id].profileId = data.log.profileId;
              factory.logs[data.log.id].profileName = data.log.profileName;
              factory.logs[data.log.id].body = data.log.body;
              return deferred.resolve(factory.logs[data.log.id]);
            }).error(function(data) {
              console.log('getlog error');
              return deferred.reject({
                msg: 'getLog error',
                err: data
              });
            })["finally"](function() {
              factory.loadingLogs--;
              return $rootScope.$broadcast('getting-logs', factory.loadingLogs);
            });
            return deferred.promise;
          }
        },
        refreshAllLogsLocation: function() {
          var i, k, log, _fn, _ref, _results,
            _this = this;
          i = 0;
          _ref = this.logs;
          _fn = function(log) {
            return $timeout(function() {
              var location;
              location = new google.maps.LatLng(log.lat, log.lng);
              return MapService.reverseGeocode(location, function(formatted_address, countryName) {
                if (_this.countries[countryName] == null) {
                  return MapService.geocode(countryName, function(location) {
                    return $.post(window.location.origin + "/log/" + log.id + "/edit", JSON.stringify({
                      country: countryName,
                      countryLat: location.lat(),
                      countryLng: location.lng()
                    }), function(resp) {
                      return console.log("updated log with new geocode");
                    });
                  });
                } else {
                  console.log("attempting geocode with existing country " + countryName);
                  return $.post(window.location.origin + "/log/" + log.id + "/edit", JSON.stringify({
                    country: countryName
                  }), function(resp) {
                    return console.log("updated log");
                  });
                }
              });
            }, 2000 * i);
          };
          _results = [];
          for (k in _ref) {
            log = _ref[k];
            _fn(log);
            _results.push(i++);
          }
          return _results;
        },
        getClosestLogs: function(logKey) {
          var change, direction, location, logPromises, _i, _len, _ref;
          logPromises = [];
          _ref = ['N', 'E', 'S', 'W'];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            direction = _ref[_i];
            change = direction === 'N' || direction === 'E' ? +1 : -1;
            if (direction === 'N' || direction === 'S') {
              location = this.logs[this.sortedLogs.lat[mod(logKey[1] + change, this.sortedLogs.lat.length)]];
            } else {
              location = this.logs[this.sortedLogs.lng[mod(logKey[0] + change, this.sortedLogs.lng.length)]];
            }
            logPromises.push(this.getLog(location.id));
          }
          return $q.all(logPromises);
        },
        getClosestLocation: function(from, direction) {
          var breakLoop, change, i, tempKey, tempLog, wrapNumber, _i, _len, _ref;
          tempKey = from.slice();
          change = direction === 'N' || direction === 'E' ? 1 : -1.;
          breakLoop = false;
          _ref = [0, 1, 2];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            wrapNumber = _ref[_i];
            if (breakLoop) {
              break;
            }
            if (direction === 'N' || direction === 'S') {
              i = Math.abs(mod(from[1] + change, this.sortedLogs.lat.length));
              while (i !== from[1]) {
                tempKey[1] = i;
                tempLog = this.sortedLogs.lat[tempKey[1]];
                tempKey = this.logs[tempLog.id].key;
                return tempKey;
                if (this.inRange(from, tempKey, direction, wrapNumber)) {
                  breakLoop = true;
                  break;
                }
                i = Math.abs(mod(i + change, this.sortedLogs.lat.length));
              }
            } else {
              i = Math.abs(mod(from[0] + change, this.sortedLogs.lng.length));
              while (i !== from[0]) {
                tempKey[0] = i;
                tempLog = this.sortedLogs.lng[tempKey[0]];
                tempKey = this.logs[tempLog.id].key;
                return tempKey;
                if (this.inRange(from, tempKey, direction, wrapNumber)) {
                  breakLoop = true;
                  break;
                }
                i = Math.abs(mod(i + change, this.sortedLogs.lng.length));
              }
            }
          }
          return tempKey;
        },
        inRange: function(from, to, direction, wrapNumber) {
          var gradient, wrapDirection;
          from = this.sortedLogs.lng[from[0]];
          to = this.sortedLogs.lng[to[0]];
          wrapDirection = direction === 'N' || direction === 'E' ? 1 : -1;
          gradient = ((to.lat + wrapDirection * wrapNumber * 90) - from.lat) / ((to.lng + wrapDirection * wrapNumber * 180) - from.lng);
          if (direction === 'N' || direction === 'S') {
            if (gradient <= -0.5 || gradient >= 0.5) {
              if (direction === 'N') {
                return to.lat >= from.lat;
              } else {
                return to.lat <= from.lat;
              }
            } else {
              return false;
            }
          } else {
            if (gradient >= -0.5 && gradient <= 0.5) {
              if (direction === 'E') {
                return to.lng >= from.lng;
              } else {
                return to.lng <= from.lng;
              }
            } else {
              return false;
            }
          }
        },
        init: function(logId) {
          var deferred;
          deferred = $q.defer();
          res.getCountries().then(function(data) {
            var country, _i, _len, _ref;
            console.log("got countries");
            _ref = data.data.countries;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              country = _ref[_i];
              factory.countries[country.id] = country;
            }
            return res.getLogs();
          }).then(function(data) {
            var i, keys, log, _i, _j, _len, _len1, _ref, _ref1;
            console.log("got logs");
            data = data.data;
            deferred.notify(0);
            factory.sortedLogs.lat = data.logs.slice().sort(function(b, a) {
              return b.lat - a.lat;
            });
            _ref = factory.sortedLogs.lat;
            for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
              log = _ref[i];
              factory.sortedLogs.lat[i] = log.id;
              factory.logs[log.id] = {
                id: log.id,
                body: null,
                title: null,
                profileId: null,
                profileName: null,
                lat: log.lat,
                lng: log.lng,
                key: [null, i]
              };
            }
            factory.sortedLogs.lng = data.logs.slice().sort(function(b, a) {
              return b.lng - a.lng;
            });
            _ref1 = factory.sortedLogs.lng;
            for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
              log = _ref1[i];
              factory.sortedLogs.lng[i] = log.id;
              factory.logs[log.id].key = [i, factory.logs[log.id].key[1]];
            }
            if (logId == null) {
              keys = Object.keys(factory.logs);
              factory.current = factory.logs[keys[(Math.random() * keys.length) >> 0]].key;
              logId = factory.sortedLogs.lng[factory.current[0]];
            } else {
              factory.current = factory.logs[logId].key;
            }
            return factory.getLog(logId).then(function(logdata) {
              deferred.notify(1);
              return factory.getClosestLogs(factory.current);
            }).then(function(data) {
              deferred.notify(2);
              return deferred.resolve(factory.logs);
            });
          });
          return deferred.promise;
        }
      };
      return factory;
    }
  ]);

  srv.factory('User', [function() {}]);

  srv.factory('MapService', [
    function() {
      var factory;
      factory = {
        idMarkerMap: {},
        geocoder: null,
        addMapMarker: null,
        miniMap: null,
        icons: {
          current: "http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png",
          visited: "http://www.google.com/intl/en_us/mapfiles/ms/micons/yellow-dot.png",
          unvisited: "http://www.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png"
        },
        currentMiniMarker: null,
        init: function() {
          var mapOptions;
          this.geocoder = new google.maps.Geocoder();
          mapOptions = {
            center: new google.maps.LatLng(20, 0),
            zoom: 1,
            styles: [
              {
                featureType: "administrative",
                stylers: [
                  {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "transit",
                stylers: [
                  {
                    color: "#000027"
                  }, {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "road",
                stylers: [
                  {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "poi",
                stylers: [
                  {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "administrative.locality",
                elementType: "labels.text.stroke",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#bfc5bf"
                  }
                ]
              }, {
                featureType: "administrative.country",
                elementType: "labels.text.stroke",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#ffffff"
                  }
                ]
              }, {
                featureType: "administrative.province",
                elementType: "labels.text.fill",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#d3d1d1"
                  }
                ]
              }, {
                featureType: "water",
                stylers: [
                  {
                    color: "#1c1c1c"
                  }
                ]
              }, {
                featureType: "landscape",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#808080"
                  }
                ]
              }
            ]
          };
          this.miniMap = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
          return angular.element("html").scope().$broadcast("map-ready");
        },
        startAddMap: function() {
          var addMap, mapOptions;
          mapOptions = {
            center: new google.maps.LatLng(0, 0),
            zoom: 1,
            styles: [
              {
                featureType: "administrative",
                stylers: [
                  {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "transit",
                stylers: [
                  {
                    color: "#000027"
                  }, {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "road",
                stylers: [
                  {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "poi",
                stylers: [
                  {
                    visibility: "off"
                  }
                ]
              }, {
                featureType: "administrative.locality",
                elementType: "labels.text.stroke",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#bfc5bf"
                  }
                ]
              }, {
                featureType: "administrative.country",
                elementType: "labels.text.stroke",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#ffffff"
                  }
                ]
              }, {
                featureType: "administrative.province",
                elementType: "labels.text.fill",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#d3d1d1"
                  }
                ]
              }, {
                featureType: "water",
                stylers: [
                  {
                    color: "#1c1c1c"
                  }
                ]
              }, {
                featureType: "landscape",
                stylers: [
                  {
                    visibility: "on"
                  }, {
                    color: "#808080"
                  }
                ]
              }
            ]
          };
          addMap = new google.maps.Map(document.getElementById("add-map-canvas"), mapOptions);
          return google.maps.event.addListener(addMap, "click", function(event) {
            angular.element("html").scope().$broadcast("addMapSelected");
            if (this.addMapMarker != null) {
              return this.addMapMarker.setPosition(event.latLng);
            } else {
              return this.addMapMarker = new google.maps.Marker({
                position: event.latLng,
                animation: google.maps.Animation.BOUNCE,
                map: addMap
              });
            }
          });
        },
        seedMap: function() {
          var dropCallback;
          dropCallback = function(resp, i) {
            return function() {
              return placeMarkerMiniMap(resp.logs[i]);
            };
          };
          return $.get("/logs", function(resp) {
            var i, _results;
            i = 0;
            _results = [];
            while (i < resp.logs.length) {
              setTimeout(dropCallback(resp, i), i * 200);
              _results.push(i++);
            }
            return _results;
          });
        },
        changeLocation: function(markerId) {
          var newMarker;
          newMarker = this.idMarkerMap[markerId];
          if (this.currentMiniMarker) {
            this.currentMiniMarker.setAnimation(null);
            this.currentMiniMarker.setIcon(this.icons.visited);
          }
          this.currentMiniMarker = newMarker;
          this.currentMiniMarker.setIcon(this.icons.current);
          if (this.currentMiniMarker.getAnimation() !== null) {
            this.currentMiniMarker.setAnimation(null);
          } else {
            this.currentMiniMarker.setAnimation(google.maps.Animation.BOUNCE);
          }
          this.miniMap.panTo(this.currentMiniMarker.position);
          if (this.miniMap.getZoom() === 1) {
            return this.miniMap.setZoom(2);
          }
        },
        switchMiniMarker: function() {
          return angular.element("html").scope().$broadcast("switch-marker", this.title);
        },
        placeMarkerMiniMap: function(log_object) {
          var marker;
          marker = new google.maps.Marker({
            position: new google.maps.LatLng(log_object.lat, log_object.lng),
            animation: google.maps.Animation.DROP,
            map: this.miniMap,
            title: log_object.id,
            icon: this.icons.unvisited
          });
          this.idMarkerMap[log_object.id] = marker;
          return google.maps.event.addListener(marker, "click", this.switchMiniMarker);
        },
        reverseGeocode: function(latlng, callback) {
          return this.geocoder.geocode({
            latLng: latlng
          }, function(results, status) {
            var component, countryName, formatted_address, _i, _len, _ref;
            if (status === google.maps.GeocoderStatus.OK) {
              if (results.length > 0) {
                formatted_address = results[0].formatted_address;
                _ref = results[0].address_components;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  component = _ref[_i];
                  if (component.types === "country" || __indexOf.call(component.types, "country") >= 0) {
                    countryName = component.long_name;
                    break;
                  }
                }
                if (countryName == null) {
                  countryName = "Other";
                }
                return typeof callback === "function" && callback(formatted_address, countryName);
              } else {
                return console.log("No results found");
              }
            } else {
              console.log("Geocoder failed due to: " + status);
              console.log(latlng);
              return typeof callback === "function" && callback("Other", "Other");
            }
          });
        },
        geocode: function(countryName, callback) {
          return this.geocoder.geocode({
            address: countryName
          }, function(results, status) {
            if (status === google.maps.GeocoderStatus.OK) {
              return typeof callback === "function" && callback(results[0].geometry.location);
            } else {
              return console.log("Geocode was not successful for the following reason: " + status);
            }
          });
        }
      };
      return factory;
    }
  ]);

}).call(this);
