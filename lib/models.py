from google.appengine.ext import ndb

class Country(ndb.Model):
  name = ndb.StringProperty(required=True)
  articles = ndb.StringProperty(repeated=True)

def query_country(name):
  return Country.query(Country.name == name).get()

def create_country(name):
  country = Country(name=name)
  country.puts()
  return country

def create_country(name):
  new_country = Country(name=name)
  new_country.put()
  return new_country

class Log(ndb.Model):
  profileId = ndb.StringProperty()
  profileName = ndb.StringProperty()
  gdriveId = ndb.StringProperty(required=True)

def create_log(gdriveId, parent):
  log = Log(parent=parent, gdriveId=gdriveId)
  return log
