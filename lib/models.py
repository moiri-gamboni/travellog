from google.appengine.ext import ndb

class Country(ndb.Model):
  pass

def query_country(name):
  return Country.query(Country.key == ndb.Key(Country, name)).get()

def get_all_countries():
  return map(lambda x: x.id(), Country.query().fetch(200, keys_only=True))

def get_country_by_key(key):
  country_key = ndb.Key(Country, key)
  return map(lambda x: x.id(), Log.query(ancestor=country_key).fetch(200, keys_only=True))

def create_country(name):
  new_country = Country(id=name)
  new_country.put()
  return new_country

class Log(ndb.Model):
  profileId = ndb.StringProperty()
  profileName = ndb.StringProperty()
  body = ndb.TextProperty()
  title = ndb.TextProperty()

def get_log_by_key(country, key):
  log = ndb.Key(Country, country, Log, key).get()
  response = {
    "id": key,
    "country": country,
    "title": log.title,
    "body": log.body
  }
  if log.profileId:
    response['profileId'] = log.profileId
  else:
    response['profileName'] = log.profileName
  return response

def create_log(gdriveId, parent):
  log = Log(parent=parent, id=gdriveId)
  return log
