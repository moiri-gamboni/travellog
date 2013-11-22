var clientId = "915895387316.apps.googleusercontent.com";
var apiKey = "AIzaSyDEaBU9ut05NvkD4_k72xRDGuVYr_ucPZc";
var scopes = "https://www.googleapis.com/auth/plus.me"+
  " https://www.googleapis.com/auth/drive" +
  " https://www.googleapis.com/auth/userinfo.profile";
function handleClientLoad() {
  // Step 2: Reference the API key
  console.log('Checking client load');
  gapi.client.setApiKey(apiKey);
  window.setTimeout(checkAuth,1);
}

function checkAuth() {
  console.log('checking auth');
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
}

function handleAuthResult(authResult) {
  console.log('Handling result');
  var successMessage = $("#loggedIn");
  var authorizeButton = $("#authorize-button");
  if (authResult && !authResult.error) {
    getUserInfo();
  }
}

$("#authorize-button").on("click", handleAuthClick);

function handleAuthClick(event) {
  console.log('handling auth click');
  // Step 3: get authorization to use private data
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, handleAuthResult);
  return false;
}

// Load the API and make an API call.  Display the results on the screen.
function getUserInfo() {
  console.log('get user info');
  // Step 4: Load the Google+ API
  gapi.client.load('plus', 'v1', function() {
    // Step 5: Assemble the API request
    var request = gapi.client.plus.people.get({
      'userId': 'me'
    });
    // Step 6: Execute the API request
    console.log("user info being gotten")
    request.execute(function(resp) {
      // if the person has no google plus id
      if (resp.code == 404) {
        gapi.client.load('oauth2', 'v2', function() {
          var request = gapi.client.oauth2.userinfo.get();
          request.execute(function(resp) {;
            setTimeout(function() {
              console.log("no google plus found");
              angular.element("html").scope().$broadcast('loggedIn', resp);
            }, 1000);
          });
        });
      } else {
        // else retrieve their information from the g+ info
        console.log("google plus found");
        setTimeout(function() {
              console.log("broadcasting")
              angular.element("html").scope().$broadcast('loggedIn', resp);
            }, 1000);
      }

    });
  });
  // load the drive client
  gapi.client.load('drive', 'v2');
}

// renders the google plus badge in the loader
function renderBadge(id) {
  div_id = $(".launch .log-author").html('<div class="g-person"' +
    'data-width="273" data-href="https://plus.google.com/' + id +
    '" data-layout="landscape" data-showcoverphoto="false"></div>').attr("id");
  gapi.person.go(div_id);
}

/**
 * Retrieve a list of File resources.
 *
 * @param {Function} callback Function to call when the request is complete.
 */
function retrieveAllFiles(callback) {
  var retrievePageOfFiles = function(request, result) {
    request.execute(function(resp) {
      result = result.concat(resp.items);
      var nextPageToken = resp.nextPageToken;
      if (nextPageToken) {
        request = gapi.client.drive.files.list({
          'pageToken': nextPageToken
        });
        retrievePageOfFiles(request, result);
      } else {
        callback(result);
      }
    });
  };
  var initialRequest = gapi.client.drive.files.list();
  retrievePageOfFiles(initialRequest, []);
}

function addToTravellog(fileId, callback) {
  var body = {
    "value": "stories@travellog.io",
    "type": "user",
    "role": "reader"
  };
  var request = gapi.client.drive.permissions.insert({
    "fileId": fileId,
    "resource": body
  });
  if (callback && typeof(callback) === "function") {
    request.execute(callback);
  }
}

function makePublic(fileId, callback) {
  var body = {
    "value": "",
    "type": "anyone",
    "role": "reader"
  };
  var request = gapi.client.drive.permissions.insert({
    "fileId": fileId,
    "resource": body
  });
  if (callback && typeof(callback) === "function") {
    request.execute(callback);
  }

}
