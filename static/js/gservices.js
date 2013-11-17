var clientId = "915895387316.apps.googleusercontent.com";
var apiKey = "AIzaSyDEaBU9ut05NvkD4_k72xRDGuVYr_ucPZc";
var scopes = "https://www.googleapis.com/auth/plus.me"+
  " https://www.googleapis.com/auth/drive" +
  " https://www.googleapis.com/auth/userinfo.profile";
function handleClientLoad() {
  // Step 2: Reference the API key
  gapi.client.setApiKey(apiKey);
  window.setTimeout(checkAuth,1);
}

function checkAuth() {
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
}

function handleAuthResult(authResult) {
  var authorizeMessage = $("#auth");
  var successMessage = $("#loggedIn");
  if (authResult && !authResult.error) {
    authorizeMessage.css({visibility:'hidden'});
    successMessage.css({visibility:'visible'});
    getUserInfo();
  } else {
    authorizeMessage.css({visibility:'visible'});
    successMessage.css({visibility:'hidden'});
    authorizeButton.onclick = handleAuthClick;
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
}
