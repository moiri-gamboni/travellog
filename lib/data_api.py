import webapp2
import json
import models

from google.appengine.ext import ndb

class DataHandler(webapp2.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = "application/json"
    self.response.out.write(json.dumps({"status": 200}))

class CreateLog(webapp2.RequestHandler):
  post_params = ["gdriveId", "country"]

  def post(self):
    self.parseJson()
    for param in self.post_params:
      if param not in self.params.keys():
        self.response.write({"status": 400, "error":\
            "You must have a %s parameter" % param})
        return
    # find the country
    country_name = self.params["country"]
    existing_country = models.query_country(country_name)    
    if not existing_country:
      existing_country = models.create_country(country_name)
    # construct the child
    log = models.create_log(self.params["gdriveId"], existing_country.key)
    if "profileId" in self.params.keys():
      log.profileId = self.params["profileId"]
    elif "profileName" in self.params.keys():
      log.profileId = self.params["profileName"]
    else:
      self.response.write({"status": 200, "error":\
          "You must have either a profileId or profileName parameter"})
      return
    log.put()
    self.response.write({"status": 200})

  def parseJson(self):
    self.params = json.loads(self.request.body)
