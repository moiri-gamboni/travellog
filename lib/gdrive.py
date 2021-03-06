#import model
import httplib2
import re
from api_keys import ACCESS_TOKEN, CLIENT_ID, CLIENT_SECRET, REFRESH_TOKEN,\
  TOKEN_EXPIRY, TOKEN_URI
from apiclient.discovery import build
from apiclient import errors
from oauth2client.client import OAuth2Credentials
from google.appengine.api import memcache
import dateutil.parser

creds = OAuth2Credentials(ACCESS_TOKEN, CLIENT_ID, CLIENT_SECRET,\
    REFRESH_TOKEN, TOKEN_EXPIRY, TOKEN_URI, None)
http = creds.authorize(httplib2.Http())
drive_service = build("drive", "v2", http=http)
memcache.add(key="largest_change_id", value=None)

def all_files():
  """Retrieves all drive files in the travellog account (debugging purpose)
  """
  result = []
  page_token = None
  while True:
    try:
      param = {}
      if page_token:
        param['pageToken'] = page_token
      files = drive_service.files().list(**param).execute()

      result.extend(files['items'])
      page_token = files.get('nextPageToken')
      if not page_token:
        break
    except errors.HttpError, error:
      print 'An error occurred: %s' % error
      break
  return result

def retrieve_all_changes():
  """Retrieve a list of Change resources.
  Args:
    drive_service: Drive API drive_service instance.
    start_change_id: ID of the change to start retrieving subsequent changes
                     from or None.
  Returns:
    List of Change resources.
  """
  result = []
  page_token = None
  largest_change_id = memcache.get("largest_change_id")
  temp_largest_change_id = None
  while True:
    try:
      param = {}
      if largest_change_id:
        param['startChangeId'] = unicode(int(largest_change_id) + 1)
      if page_token:
        param['pageToken'] = page_token
      changes = drive_service.changes().list(**param).execute()
      result.extend(changes['items'])
      page_token = changes.get('nextPageToken')
      temp_largest_change_id = changes.get("largestChangeId")
      if not page_token:
        break
    except errors.HttpError, error:
      print 'An error occurred: %s' % error
      break
  if temp_largest_change_id:
    memcache.set("largest_change_id", temp_largest_change_id)
  return result

def get_file(fileId):
  """Retrieves a single fileId and converts it to a google drive document
  """
  return drive_service.files().get(fileId=fileId).execute()

def file_to_html(drive_file):
  """Takes a google drive document and extracts its html
  """
  download_link = drive_file["exportLinks"]["text/html"]
  h = httplib2.Http()
  resp, content = h.request(download_link, "GET")
  match = re.search("<body[^>]+>(.*)</body>", content)
  if match:
    return match.group(1)
  raise Exception("Google Drive HTML Extraction" +
    "failed (perhaps the file was not a google drive file?)")
  
def process_log(log):
  drive_file = get_file(log.key.id())
  log.title = drive_file["title"]
  log.modifiedDate = dateutil.parser.parse(drive_file["modifiedDate"][:-1])
  log.body = file_to_html(drive_file)
