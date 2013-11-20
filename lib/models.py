from google.appengine.ext import ndb

class Log(ndb.Model):
  profileId = ndb.StringProperty()
  profileName = ndb.StringProperty()
  body = ndb.TextProperty()
  title = ndb.TextProperty()
  lat = ndb.FloatProperty()
  lng = ndb.FloatProperty()

def get_log_by_key(key):
  log = ndb.Key(Log, key).get()
  response = {
    "id": key,
    "title": log.title,
    "body": log.body,
    "lat": log.lat,
    "lng": log.lng
  }
  if log.profileId:
    response['profileId'] = log.profileId
  else:
    response['profileName'] = log.profileName
  return response

def get_all_logs():
  logs = Log.query().fetch(200);
  return map(lambda x: {"id": x.key.id(), "lat": x.lat, "lng": x.lng}, logs)

def create_log(gdriveId, lat, lng):
  log = Log(id=gdriveId, lat=lat, lng=lng)
  return log
