idMarkerMap = {};

function initialize() {
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
      console.log(resp.logs[i]);
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
  // push the new url
  history.pushState(currentMiniMarker.title, null,
    "/log/" + currentMiniMarker.title);
  // focus the map to the new marker
  miniMap.panTo(currentMiniMarker.position);
  if (miniMap.getZoom() == 1) {
    miniMap.setZoom(2);
  }
}

// bind the state changes to change locations
window.onpopstate = function() {
  changeLocation(history.state);
};

function switchMiniMarker() {
  changeLocation(this.title);
}


function placeMarkerMiniMap(log_object) {
  console.log(log_object);
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
                      
google.maps.event.addDomListener(window, 'load', initialize);


