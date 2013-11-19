// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  var srv;

  srv = angular.module("mainModule.services", []);

  srv.factory('test', [
    function() {
      return true;
    }
  ]);

  srv.factory('Country', [
    '$http', '$rootScope', function($http, $rootScope) {
      var factory;
      factory = {
        getCountries: function() {
          console.log("getCountries call");
          return $http.get(window.location.protocol + "//" + window.location.host + "/countries");
        },
        getCountry: function(countryName) {
          console.log("getCountry call");
          return $http.get(window.location.protocol + "//" + window.location.host + "/countries", {
            params: {
              id: countryName
            }
          });
        },
        loadCountry: function(fileIds, countryName, countryIndex) {
          var i, _i, _results;
          this.fileIds = fileIds;
          this.countryName = countryName;
          this.loadedLogs = null;
          this.countryIndex = countryIndex;
          this.logInit = fileIds.length < 3 ? fileIds.length : 3;
          this.loadLog = function() {
            return $http.get(window.location.protocol + "//" + window.location.host + "/logs/:id:country", {
              params: {
                id: fileIds[fileIds.length - 1],
                country: countryName
              }
            }).success(function(data, status, headers, config) {
              loadedLogs.push(data.result);
              fileIds.pop();
              logInit--;
              if (logInit === 0) {
                return $rootScope.$broadcast('country-init', countryIndex);
              }
            });
          };
          this.getLog = function() {
            if (loadedLogs.length !== 0) {
              return loadedLogs.pop();
            } else if (fileIds.length !== 0) {
              loadLog();
              return 1;
            } else {
              return 0;
            }
          };
          _results = [];
          for (i = _i = 1; _i <= 3; i = ++_i) {
            if (fileIds.length !== 0) {
              _results.push(loadLog());
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }
      };
      return factory;
    }
  ]);

  srv.factory('Map', [
    '$rootScope', 'Country', function($rootScope, Country) {
      var service, shuffle;
      shuffle = function(array) {
        temp;
        index;
        var counter, index, temp;
        counter = array.length;
        while (counter--) {
          index = (Math.random() * counter) | 0;
          temp = array[counter];
          array[counter] = array[index];
          array[index] = temp;
          return array;
        }
      };
      service = {
        availableCountries: [],
        loadedCountries: [],
        current: [],
        map: []
      };
      Country.getCountries().success(function(data, status, headers, config) {
        var current, i, _i, _results;
        console.log("getCountries success");
        console.log(data);
        service.availableCountries = shuffle(data.countries);
        current = [100, 1000];
        $rootScope.$on('country-init', function(event, countryIndex) {
          var i, _i, _results;
          _results = [];
          for (i = _i = -1; _i <= 1; i = ++_i) {
            _results.push(map[100 + countryIndex][1000 + i] = service.loadedCountries[countryIndex].getLog());
          }
          return _results;
        });
        _results = [];
        for (i = _i = 0; _i <= 2; i = ++_i) {
          _results.push(Country.getCountry(data.countries[data.countries.length - 1]).success(function(data, status, headers, config) {
            console.log("getCountry success");
            console.log(data);
            return service.loadedCountries.push(new Country.loadCountry(data.logs, service.availableCountries.pop(), i));
          }));
        }
        return _results;
      });
      return service;
    }
  ]);

}).call(this);