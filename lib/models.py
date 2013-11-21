from google.appengine.ext import ndb

class Log(ndb.Model):
  profileId = ndb.StringProperty()
  profileName = ndb.StringProperty()
  body = ndb.TextProperty()
  title = ndb.TextProperty()
  lat = ndb.FloatProperty(required=True)
  lng = ndb.FloatProperty(required=True)
  modifiedDate = ndb.DateTimeProperty()

def get_log_by_key(key):
  log = ndb.Key(Log, key).get()
  response = {
    "id": key,
    "title": log.title,
    "body": log.body,
    "lat": log.lat,
    "lng": log.lng,
    "modifiedDate": unicode(log.modifiedDate)
  }
  if log.profileId:
    response['profileId'] = log.profileId
  else:
    response['profileName'] = log.profileName
  return response

def get_all_logs():
  logs = Log.query().fetch(200);
  return map(lambda x: {"id": x.key.id(), "lat": x.lat, "lng": x.lng}, logs)

def get_all_logs_objects():
  logs = Log.query().fetch(200);
  resp = {}
  for log in logs:
    resp[log.key.id()] = log
  return resp

def create_log(gdriveId, lat, lng):
  log = Log(id=gdriveId, lat=lat, lng=lng)
  return log
