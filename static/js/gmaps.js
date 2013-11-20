function initialize() {
  var mapOptions = {
    center: new google.maps.LatLng(0, 0),
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
        animation: google.maps.Animation.DROP,
        map: addMap
      });
      google.maps.event.addListener(addMapMarker, 'click', toggleBounce);
    }
  });
}

function toggleBounce(event) {
  console.log(event);
  if (marker.getAnimation() !== null) {
    marker.setAnimation(null);
  } else {
    marker.setAnimation(google.maps.Animation.BOUNCE);
  }
}

function placeMarkerMiniMap(location) {
  var marker = new google.maps.Marker({
    position: location,
    map: miniMap
  });
}
                      
google.maps.event.addDomListener(window, 'load', initialize);
