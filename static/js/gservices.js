var clientId = "915895387316.apps.googleusercontent.com";
var apiKey = "AIzaSyDEaBU9ut05NvkD4_k72xRDGuVYr_ucPZc";
var scopes = "https://www.googleapis.com/auth/plus.me"+
  " https://www.googleapis.com/auth/drive" +
  " https://www.googleapis.com/auth/userinfo.profile";
function handleClientLoad() {
  // Step 2: Reference the API key
  console.log("This is working");
  gapi.client.setApiKey(apiKey);
  window.setTimeout(checkAuth,1);
}

function checkAuth() {
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
}

function handleAuthResult(authResult) {
  console.log(1)
  var successMessage = $("#loggedIn");
  var authorizeButton = $("#authorize-button");
  if (authResult && !authResult.error) {
    console.log(2)
    authorizeButton.css({visibility:'hidden'});
    successMessage.css({visibility:'visible'});
    getUserInfo();
  } else {
    console.log(3)
    successMessage.css({visibility:'hidden'});
    authorizeButton.css({visibility:'visible'}).on("click", handleAuthClick);
  }
}

function handleAuthClick(event) {
  // Step 3: get authorization to use private data
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, handleAuthResult);
  return false;
}

// Load the API and make an API call.  Display the results on the screen.
function getUserInfo() {
  // Step 4: Load the Google+ API
  gapi.client.load('plus', 'v1', function() {
    // Step 5: Assemble the API request
    var request = gapi.client.plus.people.get({
      'userId': 'me'
    });
    // Step 6: Execute the API request
    request.execute(function(resp) {
      console.log(resp);
      $("#name").html(resp.displayName);
    });
  });
  // load the drive client
  gapi.client.load('drive', 'v2');
  gapi.client.load('person', 'v1');
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
    "role": "owner"
  };
  var request = gapi.client.drive.permissions.insert({
    "fileId": fileId,
    "resource": body
  });
  request.execute(callback);

}

function makePublic(fileId) {
  var body = {
    "value": "",
    "type": "anyone",
    "role": "reader"
  };
  var request = gapi.client.drive.permissions.insert({
    "fileId": fileId,
    "resource": body
  });
  request.execute(callback);

}