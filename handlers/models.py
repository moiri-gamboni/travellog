from google.appengine.ext import ndb

class Country(ndb.Model):
  name = ndb.StringProperty(required=True, indexed=True)
  articles = ndb.StringProperty(repeated=True)

def create_country(name):
  new_country = Country(name=name)
  new_country.put()

class Log(ndb.Model):
  ids = ndb.StringProperty(required=True, indexed=True)
  name = ndb.StringProperty(required=True)
  body = ndb.StringProperty()
