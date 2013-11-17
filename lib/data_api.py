import webapp2
import json
import models

from google.appengine.ext import ndb
import gdrive

class DataHandler(webapp2.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = "application/json"
    self.response.out.write(json.dumps({"status": 200}))

class LogHandler(webapp2.RequestHandler):
  post_params = ["gdriveId", "country"]
  get_params = ["id", "country"]

  def get(self):
    # param check
    for param in self.get_params:
      if param not in self.request.arguments():
        self.response.write({"status": 400, "error":\
            "You must have a %s parameter" % param})
        return
    else:
      try:
        # try fetch the requested id by key
        self.response.write({"status": 200, "log":\
          models.get_log_by_key(self.request.get("country"),
            self.request.get("id"))})
      except:
        self.response.write({"status": 404, "error":\
          "log with id %s and country %s not found" %\
          (self.request.get("id"), self.request.get("country"))})
        return

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
      self.response.write({"status": 400, "error":\
          "You must have either a profileId or profileName parameter"})
      return
    #try:
    gdrive.process_log(log)
    #except:
      #self.response.write({"status": 400, "error":\
          #"Could not process drive document with id %s" %\
          #self.params["gdriveId"]})
      #return
    log.put()
    self.response.write({"status": 200})

  def parseJson(self):
    self.params = json.loads(self.request.body)

class CountriesHandler(webapp2.RequestHandler):
  def get(self):
    # preferably, get the ids of the articles for a specific country
    if "id" in self.request.arguments():
      try:
        self.response.write({"status": 200,\
            "logs": models.get_country_by_key(self.request.get("id"))})
      except:
        self.response.write({"status": 404, "error":\
          "country with id %s not found" % self.request.get("id")})
        return
    # if there is no param for id, return all countries
    else:
      self.response.write({"status": 200, "countries": models.get_all_countries()})

class DriveHandler(webapp2.RequestHandler):
  def get(self):
    # preferably, get the ids of the articles for a specific country
    if "id" in self.request.arguments():
      try:
        document = drive.get_file()
      except:
        self.response.write({"status": 404, "error":\
          "drive document with id %s not found" % self.request.get("id")})
    # if there is no param for id, return all drive documents
    else:
      self.response.write({"status": 200, "gdrive": gdrive.all_files()})
