#import model
import httplib2
import pprint
from api_keys import ACCESS_TOKEN, CLIENT_ID, CLIENT_SECRET, REFRESH_TOKEN, TOKEN_EXPIRY, TOKEN_URI
from apiclient.discovery import build
from oauth2client.client import OAuth2Credentials

def get_service():
  creds = OAuth2Credentials(ACCESS_TOKEN, CLIENT_ID, CLIENT_SECRET, REFRESH_TOKEN, TOKEN_EXPIRY, TOKEN_URI, None)
  http = creds.authorize(httplib2.Http())
  drive_service = build("drive", "v2", http=http)
#media_body = MediaFileUpload("model.py", mimetype='text/plain', resumable=True)
#body = {
  #'title': 'My document',
  #'description': 'A test document',
  #'mimeType': 'text/plain'
#}

#file = drive_service.files().insert(body=body, media_body=media_body).execute()
#pprint.pprint(file)
