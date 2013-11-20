idMarkerMap = {};

function initialize() {
  var mapOptions = {
    center: new google.maps.LatLng(20, 0),
    zoom: 1
  };
  miniMap = new google.maps.Map(document.getElementById("map-canvas"),
    mapOptions);
}

addMapMarker = null;
function startAddMap() {
  var mapOptions = {
    center: new google.maps.LatLng(0, 0),
    zoom: 1
  };
  addMap = new google.maps.Map(document.getElementById("add-map-canvas"),
    mapOptions);
  google.maps.event.addListener(addMap, 'click', function(event) {
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


