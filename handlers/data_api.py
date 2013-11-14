import webapp2
import json
import models

from google.appengine.ext import ndb

class DataHandler(webapp2.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = "application/json"
    self.response.out.write(json.dumps({"status": 200}))

class CreateCountry(webapp2.RequestHandler):
  def post(self):
    country_name = self.request.get("country");
    models.create_country(country_name)
    self.response.write({"hello": country})



