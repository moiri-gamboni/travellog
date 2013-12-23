from google.appengine.ext import ndb
logFields = [
    "title",
    "body",
    "lat",
    "lng",
    "country"
  ]

class Log(ndb.Model):
  profileId = ndb.StringProperty()
  profileName = ndb.StringProperty()
  country = ndb.StringProperty()
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
    "country": log.country,
    "modifiedDate": unicode(log.modifiedDate)
  }
  if log.profileId:
    response['profileId'] = log.profileId
  else:
    response['profileName'] = log.profileName
  return response

def get_log_object_by_key(key):
  return ndb.Key(Log, key).get()


def get_all_logs():
  logs = Log.query().fetch(200);
  return map(lambda x: {"id": x.key.id(), "lat": x.lat, "lng": x.lng,\
      "country": x.country}, logs)

def get_all_logs_objects():
  logs = Log.query().fetch(200);
  resp = {}
  for log in logs:
    resp[log.key.id()] = log
  return resp

def create_log(gdriveId, lat, lng):
  log = Log(id=gdriveId, lat=lat, lng=lng)
  return log

def get_country_object_by_key(country_name):
  return ndb.Key(Country, country_name).get()

def create_country(country_name, lat, lng):
  country = Country(id=country_name, lat=lat, lng=lng)
  country.put()
  return country


class Country(ndb.Model):
  lat = ndb.FloatProperty(required=True)
  lng = ndb.FloatProperty(required=True)
