window.make_request = (route, type, data, success, error) ->
  if type == "POST" or type == "PUT"
    data = JSON.stringify(data)
  if success == null
    success = ()->
  if error == null
    error = ()->
  $.ajax(
    url: window.location.protocol + "//" + window.location.host + route
    contentType: "application/json"
    data: data
    type: type
    success: success
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('ERROR: ' + errorThrown)
      raise_error_message(errorThrown+": "+textStatus)
      )

window.raise_error_message = (error_str) ->
 $('#errors').html(error_str)
