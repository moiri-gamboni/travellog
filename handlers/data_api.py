import webapp2
import json

from google.appengine.ext import ndb

class Country(ndb.Model):
  name = ndb.StringProperty(required=True, indexed=True)
  articles = ndb.StringProperty(repeated=True)

class Log(ndb.Model):
  ids = ndb.StringProperty(required=True, indexed=True)
  name = ndb.StringProperty(required=True)
  body = ndb.StringProperty()

class DataHandler(webapp2.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = "application/json"
    self.response.out.write(json.dumps({"status": 200}))
