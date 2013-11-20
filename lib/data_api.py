import webapp2
import json
import models

from google.appengine.ext import ndb
import gdrive

class LogHandler(webapp2.RequestHandler):
  post_params = ["gdriveId", "lat", "lng"]

  def get(self):
    # return all logs if id is not in the argument
    if "id" not in self.request.arguments():
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "logs":\
        models.get_all_logs()}))
    else:
      try:
        # try fetch the requested id by key
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 200, "log":\
          models.get_log_by_key(self.request.get("id"))}))
      except:
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 404, "error":\
          "log with id %s not found" %\
          (self.request.get("id"))}))
        return

  def post(self):
    self.parseJson()
    for param in self.post_params:
      if param not in self.params.keys():
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 400, "error":\
            "You must have a %s parameter" % param}))
        return
    # construct the child
    log = models.create_log(self.params["gdriveId"], self.params["lat"], self.params["lng"])
    # grab either a profileId or profileName depending on what was passed in
    if "profileId" in self.params.keys():
      log.profileId = self.params["profileId"]
    elif "profileName" in self.params.keys():
      log.profileId = self.params["profileName"]
    else:
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 400, "error":\
          "You must have either a profileId or profileName parameter"}))
      return
    try:
      # process the log, fetching its html content
      gdrive.process_log(log)
    except:
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 400, "error":\
          "Could not process drive document with id %s" %\
          self.params["gdriveId"]}))
      return
    log.put()
    self.response.headers['Content-Type'] = "application/json"
    self.response.write(json.dumps({"status": 200}))

  def parseJson(self):
    self.params = json.loads(self.request.body)

class DriveHandler(webapp2.RequestHandler):
  def get(self):
    # preferably, get the ids of the articles for a specific country
    if "id" in self.request.arguments():
      try:
        document = drive.get_file()
      except:
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 404, "error":\
          "drive document with id %s not found" % self.request.get("id")}))
    # if there is no param for id, return all drive documents
    else:
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "gdrive": gdrive.all_files()}))
