idMarkerMap = {};
var geocoder;

function initialize() {
  geocoder = new google.maps.Geocoder();
  var mapOptions = {
    center: new google.maps.LatLng(20, 0),
    zoom: 1,
    styles: [
  {
    "featureType": "administrative",
    "stylers": [
      { "visibility": "off" }
    ]
  },{
    "featureType": "transit",
    "stylers": [
      { "color": "#000027" },
      { "visibility": "off" }
    ]
  },{
    "featureType": "road",
    "stylers": [
      { "visibility": "off" }
    ]
  },{
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },{
    "featureType": "administrative.locality",
    "elementType": "labels.text.stroke",
    "stylers": [
      { "visibility": "on" },
      { "color": "#bfc5bf" }
    ]
  },{
    "featureType": "administrative.country",
    "elementType": "labels.text.stroke",
    "stylers": [
      { "visibility": "on" },
      { "color": "#ffffff" }
    ]
  },{
    "featureType": "administrative.province",
    "elementType": "labels.text.fill",
    "stylers": [
      { "visibility": "on" },
      { "color": "#d3d1d1" }
    ]
  },{
    "featureType": "water",
    "stylers": [
      { "color": "#1c1c1c" }
    ]
  },{
    "featureType": "landscape",
    "stylers": [
      { "visibility": "on" },
      { "color": "#808080" }
    ]
  }
]
  };
  miniMap = new google.maps.Map(document.getElementById("map-canvas"),
    mapOptions);
  angular.element("html").scope().$broadcast('map-ready');
}

addMapMarker = null;
function startAddMap() {
  var mapOptions = {
    center: new google.maps.LatLng(0, 0),
    zoom: 1,
    styles: [
  {
    "featureType": "administrative",
    "stylers": [
      { "visibility": "off" }
    ]
  },{
    "featureType": "transit",
    "stylers": [
      { "color": "#000027" },
      { "visibility": "off" }
    ]
  },{
    "featureType": "road",
    "stylers": [
      { "visibility": "off" }
    ]
  },{
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },{
    "featureType": "administrative.locality",
    "elementType": "labels.text.stroke",
    "stylers": [
      { "visibility": "on" },
      { "color": "#bfc5bf" }
    ]
  },{
    "featureType": "administrative.country",
    "elementType": "labels.text.stroke",
    "stylers": [
      { "visibility": "on" },
      { "color": "#ffffff" }
    ]
  },{
    "featureType": "administrative.province",
    "elementType": "labels.text.fill",
    "stylers": [
      { "visibility": "on" },
      { "color": "#d3d1d1" }
    ]
  },{
    "featureType": "water",
    "stylers": [
      { "color": "#1c1c1c" }
    ]
  },{
    "featureType": "landscape",
    "stylers": [
      { "visibility": "on" },
      { "color": "#808080" }
    ]
  }
]};
  addMap = new google.maps.Map(document.getElementById("add-map-canvas"),
    mapOptions);
  google.maps.event.addListener(addMap, 'click', function(event) {
    angular.element("html").scope().$broadcast('addMapSelected');
    if (addMapMarker) {
      addMapMarker.setPosition(event.latLng);
    } else {
    addMapMarker = new google.maps.Marker({
      position: event.latLng,
      animation: google.maps.Animation.BOUNCE,
      map: addMap
    });
    }
  });
}

function seedMap() {
  function dropCallback(resp, i) {
    return function() {
      placeMarkerMiniMap(resp.logs[i]);
    };
  }
  $.get("/logs", function(resp) {
    for (var i=0; i < resp.logs.length; i++) {
      setTimeout(dropCallback(resp, i), i * 200);
    }
  });
}
// different icons
icons = {
  current: 'http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png',
  visited: 'http://www.google.com/intl/en_us/mapfiles/ms/micons/yellow-dot.png',
  unvisited: 'http://www.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png'
};

currentMiniMarker = null;
// click handler for a minimap item
function changeLocation(markerId) {
  newMarker = idMarkerMap[markerId];
  // deselct the old one if it exists
  if (currentMiniMarker) {
    currentMiniMarker.setAnimation(null);
    currentMiniMarker.setIcon(icons.visited);
  }
  currentMiniMarker = newMarker;
  // set the current color
  currentMiniMarker.setIcon(icons.current);
  // start the bouncing
  if (currentMiniMarker.getAnimation() !== null) {
    currentMiniMarker.setAnimation(null);
  } else {
    currentMiniMarker.setAnimation(google.maps.Animation.BOUNCE);
  }
  // focus the map to the new marker
  miniMap.panTo(currentMiniMarker.position);
  if (miniMap.getZoom() == 1) {
    miniMap.setZoom(2);
  }
}


function switchMiniMarker() {
  angular.element("html").scope().$broadcast('switch-marker', this.title);
}


function placeMarkerMiniMap(log_object) {
  var marker = new google.maps.Marker({
    position: new google.maps.LatLng(log_object.lat, log_object.lng),
      animation: google.maps.Animation.DROP,
    map: miniMap,
    title: log_object.id,
    icon: icons.unvisited
  });
  idMarkerMap[log_object.id] = marker;
  google.maps.event.addListener(marker, 'click', switchMiniMarker);
}

// reverse geocoder modified from code example
function reverseGeocode(latlng, callback) {
  geocoder.geocode({'latLng': latlng}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        console.log("Results are:");
        var formatted_address = results[1].formatted_address;
        var countryName = results[1].address_components[results[1].address_components.length - 1].long_name;
        console.log(formatted_address);
        console.log(countryName);
        typeof callback === 'function' && callback(formatted_address, countryName);
      } else {
        console.log('No results found');
      }
    } else {
      console.log('Geocoder failed due to: ' + status);
    }
  });
}

function geocode(countryName, callback) {
  geocoder.geocode( { 'address': countryName}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      map.setCenter(results[0].geometry.location);
      var marker = new google.maps.Marker({
          map: map,
          position: results[0].geometry.location
      });
    } else {
      alert('Geocode was not successful for the following reason: ' + status);
    }
  });
}

