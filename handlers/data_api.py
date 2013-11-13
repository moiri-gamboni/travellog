import webapp2
import json

from google.appengine.ext import ndb

class DataHandler(webapp2.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = "application/json"
    self.response.out.write(json.dumps({"status": 200}))


