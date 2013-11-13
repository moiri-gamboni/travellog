import json
import requests

with open("secrets.json") as f:
  data = json.loads(f.read())

print "First Request URL (replace scope)"
print data["web"]["auth_uri"] + "?response_type=code" + "&client_id=" +\
  data["web"]["client_id"] + "&redirect_uri=" +\
  data["web"]["redirect_uris"][0] + "&scope={A,B,C}" + "&access_type=offline"
code = raw_input("Please input the code Google returned:\n")
token_request = {
    "code": code,
    "client_id": data["web"]["client_id"],
    "client_secret": data["web"]["client_secret"],
    "redirect_uri": data["web"]["redirect_uris"][0],
    "grant_type": "authorization_code"
}
response = requests.post(data["web"]["token_uri"],\
    data=token_request)

print response.text

